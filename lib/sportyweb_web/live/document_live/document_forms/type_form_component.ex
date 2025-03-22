defmodule SportywebWeb.DocumentLive.TypeFormComponent do
  use SportywebWeb, :live_component

  @impl true
  def update(assigns, socket) do
    entity_id = assigns[:entity] && assigns.entity.id
    extension_module = assigns[:extension_module]

    extension = assigns[:extension] || struct(extension_module, %{contact_id: entity_id})
    changeset = extension_module.changeset(extension, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="col-span-12">
      <.input
        field={@form[:type]}
        type="select"
        label="Dokumententyp"
        options={Enum.map(@extension_module.get_valid_types(), fn type -> {type[:key], type[:value]} end)}
      />
    </div>
    """
  end
end
