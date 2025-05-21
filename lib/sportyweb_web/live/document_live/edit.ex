defmodule SportywebWeb.DocumentLive.Edit do
  use SportywebWeb, :live_view

  require Logger

  alias Sportyweb.Documents
  alias Sportyweb.Documents.Document
  alias SportywebWeb.DocumentLive.DocumentConfig
  alias Sportyweb.Repo
  alias Sportyweb.Documents.DocumentLogEntry
  alias Sportyweb.Documents.DocumentComment

  import SportywebWeb.DocumentFormFieldsComponent

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:full_width, true)
      |> assign(:show_form, false)
      |> assign(:changed, false)
      |> assign(:show_delete_modal, false)

    Logger.debug("mount: show_delete_modal=#{inspect(socket.assigns.show_delete_modal)}")

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    document =
      Documents.get_document!(id,
        document_logs: [:changed_by],
        document_comments: [:commented_by]
      )

    cond do
      socket.assigns.live_action == :public and not document.public ->
        {:noreply, redirect(socket, to: "/")}

      true ->
        socket = apply_edit(socket, document)
        {:noreply, setup_changesets(socket)}
    end
  end

  defp apply_edit(socket, document) do
    case Documents.get_document_extension(document) do
      {type, extension} ->
        config = DocumentConfig.get_config(Atom.to_string(type))
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

  # Initialisiert Changesets und Form-Assigns basierend auf den aktuellen Assigns.
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

    comment_changeset = DocumentComment.changeset(%DocumentComment{}, %{})

    socket
    |> assign(:extension, extension)
    |> assign(:document_changeset, document_changeset)
    |> assign(:extension_changeset, extension_changeset)
    |> assign(:comment_changeset, comment_changeset)
    |> assign(:form_comment, to_form(comment_changeset))
    |> assign(:form_document, to_form(document_changeset))
    |> assign(:form_extension, to_form(extension_changeset))
    |> assign(
      :changed,
      map_size(document_changeset.changes) > 0 or
        map_size(extension_changeset.changes) > 0
    )
  end

  @impl true
  def handle_event("save_comment", params, socket) do
    comment_params = Map.get(params, "document_comment", %{})

    attrs =
      comment_params
      |> Map.put("document_id", socket.assigns.document.id)
      |> Map.put("commented_by_id", socket.assigns.current_user.id)

    changeset = DocumentComment.changeset(%DocumentComment{}, attrs)

    case Repo.insert(changeset) do
      {:ok, _} ->
        document =
          Documents.get_document!(socket.assigns.document.id,
            document_logs: [:changed_by],
            document_comments: [:commented_by]
          )

        new_cs = DocumentComment.changeset(%DocumentComment{}, %{})

        {:noreply,
         socket
         |> assign(:document, document)
         |> assign(:comment_changeset, new_cs)
         |> assign(:form_comment, to_form(new_cs))}

      {:error, cs} ->
        {:noreply,
         socket
         |> assign(:comment_changeset, cs)
         |> assign(:form_comment, to_form(cs))}
    end
  end

  @impl true
  def handle_event("show_form", _params, socket) do
    {:noreply, assign(socket, show_form: true)}
  end

  @impl true
  def handle_event("hide_form", _params, socket) do
    {:noreply, assign(socket, show_form: false)}
  end

  @impl true
  def handle_event("show_delete_modal", _params, socket) do
    Logger.debug(
      "show_delete_modal event: before assign=#{inspect(socket.assigns.show_delete_modal)}"
    )

    {:noreply, assign(socket, show_delete_modal: true)}
  end

  @impl true
  def handle_event("hide_delete_modal", _params, socket) do
    Logger.debug(
      "hide_delete_modal event: before assign=#{inspect(socket.assigns.show_delete_modal)}"
    )

    {:noreply, assign(socket, show_delete_modal: false)}
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
      |> assign(
        :changed,
        !socket.assigns.document.locked and
          (map_size(document_changeset.changes) > 0 or
             map_size(extension_changeset.changes) > 0)
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", params, socket) do
    doc_params = Map.get(params, "document", %{})
    ext_key = socket.assigns.form_extension.name
    ext_params = Map.get(params, ext_key, %{})

    case socket.assigns.live_action do
      :edit -> update_document(socket, doc_params, ext_params)
    end
  end

  @impl true
  def handle_event("delete", _params, socket) do
    document = socket.assigns.document

    deleted_at = DateTime.utc_now() |> DateTime.truncate(:second)
    changeset = Ecto.Changeset.change(document, deleted_at: deleted_at)

    result =
      Repo.transaction(fn ->
        with {:ok, doc} <- Repo.update(changeset) do
          log_params = %{
            "document_id" => doc.id,
            "changed_by_id" => socket.assigns.current_user.id,
            "action" => "delete"
          }

          log_changeset =
            DocumentLogEntry.changeset(
              %DocumentLogEntry{},
              log_params
            )

          case Repo.insert(log_changeset) do
            {:ok, _log_entry} ->
              {:ok, doc}

            {:error, log_cs} ->
              Repo.rollback(log_cs)
          end
        else
          {:error, cs} ->
            Repo.rollback(cs)
        end
      end)

    case result do
      {:ok, _doc} ->
        {:noreply,
         socket
         |> put_flash(:info, "Dokument wurde gelöscht.")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Fehler beim Löschen des Dokuments.")}
    end
  end

  @impl true
  def handle_event("publish", _params, socket) do
    document = socket.assigns.document
    changeset = Ecto.Changeset.change(document, public: true)

    result =
      Repo.transaction(fn ->
        with {:ok, updated_doc} <- Repo.update(changeset) do
          log_params = %{
            "document_id" => updated_doc.id,
            "changed_by_id" => socket.assigns.current_user.id,
            "action" => "update",
            "changes" => changeset.changes
          }

          log_changeset =
            DocumentLogEntry.changeset(
              %DocumentLogEntry{},
              log_params
            )

          case Repo.insert(log_changeset) do
            {:ok, _log_entry} ->
              updated_doc

            {:error, log_cs} ->
              Repo.rollback(log_cs)
          end
        else
          {:error, cs} ->
            Repo.rollback(cs)
        end
      end)

    case result do
      {:ok, updated_doc} ->
        reloaded_document =
          Documents.get_document!(updated_doc.id,
            document_logs: [:changed_by],
            document_comments: [:commented_by]
          )

        updated_socket =
          socket
          |> assign(:document, reloaded_document)
          |> setup_changesets()

        {:noreply,
         updated_socket
         |> put_flash(:info, "Dokument wurde veröffentlicht.")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Fehler beim Veröffntlichen des Dokuments.")}
    end
  end

  @impl true
  def handle_event("unpublish", _params, socket) do
    document = socket.assigns.document
    changeset = Ecto.Changeset.change(document, public: false)

    result =
      Repo.transaction(fn ->
        with {:ok, updated_doc} <- Repo.update(changeset) do
          log_params = %{
            "document_id" => updated_doc.id,
            "changed_by_id" => socket.assigns.current_user.id,
            "action" => "update",
            "changes" => changeset.changes
          }

          log_changeset =
            DocumentLogEntry.changeset(
              %DocumentLogEntry{},
              log_params
            )

          case Repo.insert(log_changeset) do
            {:ok, _log_entry} ->
              updated_doc

            {:error, log_cs} ->
              Repo.rollback(log_cs)
          end
        else
          {:error, cs} ->
            Repo.rollback(cs)
        end
      end)

    case result do
      {:ok, updated_doc} ->
        reloaded_document =
          Documents.get_document!(updated_doc.id,
            document_logs: [:changed_by],
            document_comments: [:commented_by]
          )

        updated_socket =
          socket
          |> assign(:document, reloaded_document)
          |> setup_changesets()

        {:noreply,
         updated_socket
         |> put_flash(:info, "Dokument wurde zurückgezogen.")}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Fehler beim Zurückziehen des Dokuments.")}
    end
  end

  @impl true
  def handle_event("copy_flash", _params, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Freigabelink wurde in die Zwischenablage kopiert!")}
  end

  defp update_document(socket, doc_params, ext_params) do
    document_changeset = Document.changeset(socket.assigns.document, doc_params)

    extension_changeset =
      socket.assigns.extension_module.changeset(socket.assigns.extension, ext_params)

    result =
      Repo.transaction(fn ->
        with {:ok, document} <- Repo.update(document_changeset),
             {:ok, _extension} <- Repo.update(extension_changeset) do
          log_params = %{
            "document_id" => document.id,
            "changed_by_id" => socket.assigns.current_user.id,
            "action" => "update",
            "changes" => document_changeset.changes,
            "extension_changes" => extension_changeset.changes
          }

          log_changeset =
            DocumentLogEntry.changeset(
              %DocumentLogEntry{},
              log_params
            )

          case Repo.insert(log_changeset) do
            {:ok, _log_entry} ->
              {:ok, document}

            {:error, log_cs} ->
              Repo.rollback(log_cs)
          end
        else
          {:error, changeset} ->
            Repo.rollback(changeset)
        end
      end)

    case result do
      {:ok, _doc} ->
        {:noreply,
         if socket.assigns.show_form do
           socket
           |> put_flash(:info, "Dokument erfolgreich aktualisiert.")
           |> assign(:show_form, false)
         else
           socket
           |> put_flash(:info, "Dokument erfolgreich aktualisiert.")
           |> push_navigate(to: socket.assigns.navigate)
         end}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Fehler beim Aktualisieren.")
         |> assign(
           form_document: to_form(document_changeset),
           form_extension: to_form(extension_changeset)
         )}
    end
  end
end
