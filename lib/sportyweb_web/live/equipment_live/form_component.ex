defmodule SportywebWeb.EquipmentLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Asset

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage equipment records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="equipment-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="Name" />
        <.input field={{f, :reference_number}} type="text" label="Reference number" />
        <.input field={{f, :serial_number}} type="text" label="Serial number" />
        <.input field={{f, :description}} type="text" label="Description" />
        <.input field={{f, :purchased_at}} type="date" label="Purchased at" />
        <.input field={{f, :commission_at}} type="date" label="Commission at" />
        <.input field={{f, :decommission_at}} type="date" label="Decommission at" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Equipment</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{equipment: equipment} = assigns, socket) do
    changeset = Asset.change_equipment(equipment)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"equipment" => equipment_params}, socket) do
    changeset =
      socket.assigns.equipment
      |> Asset.change_equipment(equipment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"equipment" => equipment_params}, socket) do
    save_equipment(socket, socket.assigns.action, equipment_params)
  end

  defp save_equipment(socket, :edit, equipment_params) do
    case Asset.update_equipment(socket.assigns.equipment, equipment_params) do
      {:ok, _equipment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Equipment updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_equipment(socket, :new, equipment_params) do
    case Asset.create_equipment(equipment_params) do
      {:ok, _equipment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Equipment created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
