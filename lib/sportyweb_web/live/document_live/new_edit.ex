defmodule SportywebWeb.DocumentLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Documents
  alias Sportyweb.Documents.Document
  alias SportywebWeb.DocumentLive.DocumentConfig
  alias Sportyweb.Repo
  alias Sportyweb.Documents.Storage

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket =
      case socket.assigns.live_action do
        :edit -> apply_edit(socket, params)
        :new -> apply_new(socket, params)
      end

    {:noreply, setup_changesets(socket)}
  end

  defp apply_edit(socket, %{"id" => id}) do
    document = Documents.get_document!(id)

    case Documents.get_document_extension(document) do
      {type, extension} ->
        config = DocumentConfig.get_config(type)
        related_entity = config.get_entity.(extension)

        socket
        |> assign(:document, document)
        |> assign(:extension, extension)
        |> assign(:extension_module, config.extension_module)
        |> assign(:related_entity, related_entity)
        |> assign(:related_type, config.related_type)
        |> assign(:extension_form_component, config.form_component)
        |> assign(:page_title, "Dokument bearbeiten")
        |> assign(:navigate, config.navigate_back.(related_entity))

      nil ->
        raise "No document extension found for document #{document.id}"
    end
  end

  defp apply_new(socket, %{"ref" => reference_id, "type" => type_str}) do
    document_type = String.to_existing_atom(type_str)
    config = DocumentConfig.get_config(document_type)
    related_entity = config.load_entity.(reference_id)

    socket
    |> assign(:document, %Document{})
    |> assign(:extension, nil)
    |> assign(:extension_module, config.extension_module)
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
      :edit -> update_document(socket, doc_params, ext_params)
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

        IO.puts("==> Upload: Speichere Datei mit Storage.store_file/2")
        Storage.store_file(upload, Ecto.UUID.generate())
      end)
      |> List.first()

    case uploaded_file do
      nil ->
        IO.puts("==> Fehler: Keine Datei hochgeladen")
        {:noreply, put_flash(socket, :error, "Es wurde keine Datei ausgewählt.")}
      doc_data ->
        IO.inspect(doc_data, label: "==> Hochgeladene Datei")
        result =
          Repo.transaction(fn ->
            IO.puts("==> Erstelle Document-Changeset")
            document_params =
              Map.merge(doc_params, %{
                "filename" => doc_data.filename,
                "content_type" => doc_data.content_type,
                "byte_size" => doc_data.byte_size,
                "storage_path" => doc_data.storage_path,
                "thumbnail_path" => doc_data.thumbnail_path,
                "checksum" => doc_data.checksum,
                "uploaded_by_id" => socket.assigns.current_user.id
              })

            document_changeset =
              Document.changeset(%Document{}, document_params)
              |> Map.put(:action, :insert)

            case Repo.insert(document_changeset) do
              {:ok, document} ->
                IO.puts("==> Document erfolgreich gespeichert")
                IO.inspect(document, label: "==> Document")

                extension_params =
                  ext_params
                  |> Map.merge(%{
                    "document_id" => document.id,
                    "#{socket.assigns.related_type}_id" => socket.assigns.related_entity.id
                  })

                IO.inspect(extension_params, label: "==> Extension Params")

                extension_changeset =
                  socket.assigns.extension_module.changeset(
                    struct(socket.assigns.extension_module),
                    extension_params
                  )
                  |> Map.put(:action, :insert)

                IO.inspect(extension_changeset, label: "==> Extension Changeset")

                case Repo.insert(extension_changeset) do
                  {:ok, _extension} ->
                    IO.puts("==> Extension erfolgreich gespeichert")
                    {:ok, document}
                  {:error, changeset} ->
                    IO.puts("==> Fehler beim Speichern der Extension")
                    IO.inspect(changeset.errors, label: "==> Extension Fehler")
                    Repo.rollback({:extension_failed, changeset})
                end

              {:error, changeset} ->
                IO.puts("==> Fehler beim Speichern des Dokuments")
                IO.inspect(changeset.errors, label: "==> Document Fehler")
                Repo.rollback({:document_failed, changeset})
            end
          end)

        case result do
          {:ok, _doc} ->
            {:noreply,
             socket
             |> put_flash(:info, "Dokument erfolgreich hochgeladen.")
             |> push_navigate(to: socket.assigns.navigate)}
          {:error, {:document_failed, changeset}} ->
            {:noreply,
             socket
             |> put_flash(:error, "Fehler beim Speichern des Dokuments.")
             |> assign(:form_document, to_form(changeset))}
          {:error, {:extension_failed, changeset}} ->
            {:noreply,
             socket
             |> put_flash(:error, "Fehler beim Speichern der Dokumenten-Erweiterung.")
             |> assign(:form_extension, to_form(changeset))}
          _ ->
            {:noreply, socket |> put_flash(:error, "Unbekannter Fehler.")}
        end
    end
  end

  defp update_document(socket, doc_params, ext_params) do
    document_changeset = Document.changeset(socket.assigns.document, doc_params)
    extension_changeset = socket.assigns.extension_module.changeset(socket.assigns.extension, ext_params)

    result =
      Repo.transaction(fn ->
        with {:ok, document} <- Repo.update(document_changeset),
             {:ok, _extension} <- Repo.update(extension_changeset) do
          {:ok, document}
        else
          {:error, changeset} -> Repo.rollback(changeset)
        end
      end)

    case result do
      {:ok, _doc} ->
        {:noreply,
         socket
         |> put_flash(:info, "Dokument erfolgreich aktualisiert.")
         |> push_navigate(to: socket.assigns.navigate)}
      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Fehler beim Aktualisieren.")
         |> assign(:form_document, to_form(document_changeset))
         |> assign(:form_extension, to_form(extension_changeset))}
    end
  end
end
