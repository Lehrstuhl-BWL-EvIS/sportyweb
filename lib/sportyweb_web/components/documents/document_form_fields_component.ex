defmodule SportywebWeb.DocumentFormFieldsComponent do
  use Phoenix.Component
  import SportywebWeb.CoreComponents

  def format_field(key, value) do
    case key do
      "title" -> {"Titel",value}
      "description" -> {"Beschreibung",value}
      "locked" -> {"Gesperrt",if(value == true or value == "true", do: "Ja", else: "Nein")} # Checkboxes are currently wrongly encoded as string, but only when creating! Update works fine...
      "public" -> {"Freigegeben",if(value == true or value == "true", do: "Ja", else: "Nein")} # Needs to be fixed in the future.
      _ -> {key,inspect(value)}
    end
  end

  attr :form_document, Phoenix.HTML.Form, required: true
  attr :form_extension, Phoenix.HTML.Form, required: true
  attr :extension_form_component, :any, required: true
  attr :extension_module, :any, required: true
  attr :extension_changeset, Ecto.Changeset, required: true
  attr :with_upload, :any, required: true
  attr :uploads, :any, required: false
  attr :readonly, :any, required: true

  def document_form_fields(assigns) do
    ~H"""
    <.input_grids class="gap-y-2">
      <.input_grid class="gap-y-2">
        <div class="col-span-12">
          <.input field={@form_document[:title]} disabled={@readonly} type="text" label="Titel" />
        </div>
        <div class="col-span-12">
          <.input
            field={@form_document[:description]}
            disabled={@readonly}
            type="textarea"
            label="Beschreibung"
          />
        </div>

        <.live_component
          module={@extension_form_component}
          id="doc-type-form"
          form={@form_extension}
          readonly={@readonly}
          extension_module={@extension_module}
          changeset={@extension_changeset}
        />
        <%= if @with_upload and !@readonly do %>
          <div class="col-span-12 mb-2">
            <.label for="new-file-input">Datei auswählen</.label>
            <.live_file_input upload={@uploads.file} id="new-file-input" class="file-input" />
          </div>
        <% end %>
        <div class="col-span-12">
          <.input
            field={@form_document[:locked]}
            disabled={@readonly}
            type="checkbox"
            label="Änderungen sperren"
          />
        </div>
      </.input_grid>
    </.input_grids>
    """
  end
end
