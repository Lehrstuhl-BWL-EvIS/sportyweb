defmodule SportywebWeb.DocumentLive.New do
  use SportywebWeb, :live_view

  alias Sportyweb.Documents.Document
  alias SportywebWeb.DocumentLive.DocumentConfig
  alias Sportyweb.Repo
  alias Sportyweb.Documents.Storage
  alias Sportyweb.Documents.DocumentLogEntry

  import SportywebWeb.DocumentFormFieldsComponent

  @impl true
  def mount(_params, _session, socket) do
    ip =
      case get_connect_info(socket, :peer_data) do
        %{address: ip_tuple} -> :inet.ntoa(ip_tuple) |> to_string()
        _ -> "unknown"
      end

    {:ok, assign(socket, ip_address: ip)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket =
      case socket.assigns.live_action do
        :new -> apply_new(socket, params)
      end

    {:noreply, setup_changesets(socket)}
  end

  defp apply_new(socket, %{"ref" => reference_id, "type" => type_str}) do
    config = DocumentConfig.get_config(type_str)
    related_entity = config.load_entity.(reference_id)

    socket
    |> assign(:document, %Document{})
    |> assign(:extension, nil)
    |> assign(:extension_module, config.extension_module)
    |> assign(:club, config.get_club.(related_entity))
    |> assign(:related_entity, related_entity)
    |> assign(:related_type, config.related_type)
    |> assign(:extension_form_component, config.form_component)
    |> assign(:page_title, "Neues Dokument anlegen")
    |> assign(:navigate, config.navigate_back.(related_entity))
  end

  # Initializes changesets and form assigns based on current assigns.
  defp setup_changesets(socket) do
    document = socket.assigns.document
    document_changeset = Document.changeset(document, %{})

    extension =
      if is_nil(socket.assigns.extension) do
        struct(socket.assigns.extension_module, %{
          "#{socket.assigns.related_type}_id" => socket.assigns.related_entity.id
        })
      else
        socket.assigns.extension
      end

    extension_changeset = socket.assigns.extension_module.changeset(extension, %{})

    socket
    |> assign(:extension, extension)
    |> allow_upload(:file,
      accept: ~w(.pdf),
      max_entries: 1,
      max_file_size: 10_000_000
    )
    |> assign(:document_changeset, document_changeset)
    |> assign(:extension_changeset, extension_changeset)
    |> assign(:form_document, to_form(document_changeset))
    |> assign(:form_extension, to_form(extension_changeset))
  end

  @impl true
  def handle_event("validate", params, socket) do
    doc_params = Map.get(params, "document", %{})
    ext_key = socket.assigns.form_extension.name
    ext_params = Map.get(params, ext_key, %{})

    document_changeset =
      Document.changeset(socket.assigns.document, doc_params)
      |> Map.put(:action, :validate)

    extension_changeset =
      socket.assigns.extension_module.changeset(socket.assigns.extension, ext_params)
      |> Map.put(:action, :validate)

    socket =
      socket
      |> assign(:document_changeset, document_changeset)
      |> assign(:extension_changeset, extension_changeset)
      |> assign(:form_document, to_form(document_changeset))
      |> assign(:form_extension, to_form(extension_changeset))

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", params, socket) do
    doc_params = Map.get(params, "document", %{})
    ext_key = socket.assigns.form_extension.name
    ext_params = Map.get(params, ext_key, %{})

    case socket.assigns.live_action do
      :new -> create_document(socket, doc_params, ext_params)
    end
  end

  defp create_document(socket, doc_params, ext_params) do
    uploaded_file =
      consume_uploaded_entries(socket, :file, fn %{path: path}, entry ->
        upload = %Plug.Upload{
          path: path,
          filename: entry.client_name,
          content_type: entry.client_type
        }

        Storage.store_file(upload, Ecto.UUID.generate())
      end)
      |> List.first()

    case uploaded_file do
      nil ->
        {:noreply, put_flash(socket, :error, "Es wurde keine Datei ausgewählt.")}

      doc_data ->
        result =
          Repo.transaction(fn ->
            document_params =
              Map.merge(doc_params, %{
                "filename" => doc_data.filename,
                "content_type" => doc_data.content_type,
                "byte_size" => doc_data.byte_size,
                "fulltext" => doc_data.fulltext,
                "storage_path" => doc_data.storage_path,
                "thumbnail_path" => doc_data.thumbnail_path,
                "checksum" => doc_data.checksum,
                "uploaded_by_id" => socket.assigns.current_user.id,
                "club_id" => socket.assigns.club.id
              })

            document_changeset =
              Document.changeset(%Document{}, document_params)
              |> Map.put(:action, :insert)

            with {:ok, document} <- Repo.insert(document_changeset) do
              extension_params =
                ext_params
                |> Map.merge(%{
                  "document_id" => document.id,
                  "#{socket.assigns.related_type}_id" => socket.assigns.related_entity.id
                })

              extension_changeset =
                socket.assigns.extension_module.changeset(
                  struct(socket.assigns.extension_module),
                  extension_params
                )
                |> Map.put(:action, :insert)

              with {:ok, _extension} <- Repo.insert(extension_changeset) do
                log_params = %{
                  "document_id" => document.id,
                  "changed_by_id" => socket.assigns.current_user.id,
                  "action" => "create",
                  "changes" => doc_params,
                  "extension_changes" => ext_params,
                  "ip_address" => socket.assigns.ip_address
                }

                log_changeset =
                  DocumentLogEntry.changeset(
                    %DocumentLogEntry{},
                    log_params
                  )

                case Repo.insert(log_changeset) do
                  {:ok, _log_entry} ->
                    {:ok, document}

                  {:error, _log_cs} ->
                    Repo.rollback(:log_failed)
                end
              else
                {:error, _ext_cs} -> Repo.rollback(:extension_failed)
              end
            else
              {:error, _doc_cs} -> Repo.rollback(:document_failed)
            end
          end)

        case result do
          {:ok, _doc} ->
            {:noreply,
             socket
             |> put_flash(:info, "Dokument erfolgreich hochgeladen.")
             |> push_navigate(to: socket.assigns.navigate)}

          {:error, _reason} ->
            {:noreply,
             socket
             |> put_flash(:error, "Fehler beim Speichern.")
             |> assign(
               form_document: to_form(Document.changeset(%Document{}, doc_params)),
               form_extension:
                 to_form(
                   socket.assigns.extension_module.changeset(
                     struct(socket.assigns.extension_module),
                     ext_params
                   )
                 )
             )}
        end
    end
  end
end
