defmodule SportywebWeb.EquipmentLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Asset

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.card>
        <.simple_form
          for={@form}
          id="equipment-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input_grids>
            <.input_grid>
              <%= if @equipment.id do %>
                <div class="col-span-12">
                  <.input
                    field={@form[:venue_id]}
                    type="select"
                    label="Standort"
                    options={Asset.list_venues(@equipment.venue.club_id) |> Enum.map(&{&1.name, &1.id})}
                  />
                </div>
              <% end %>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:name]} type="text" label="Name" />
              </div>

              <div class="col-span-12 md:col-span-3">
                <.input field={@form[:reference_number]} type="text" label="Referenznummer (optional)" />
              </div>

              <div class="col-span-12 md:col-span-3">
                <.input field={@form[:serial_number]} type="text" label="Seriennummer (optional)" />
              </div>

              <div class="col-span-12">
                <.input field={@form[:description]} type="textarea" label="Beschreibung (optional)" />
              </div>

              <div class="col-span-12 md:col-span-4">
                <.input field={@form[:purchase_date]} type="date" label="Gekauft am (optional)" />
              </div>

              <div class="col-span-12 md:col-span-4">
                <.input field={@form[:commission_date]} type="date" label="Nutzung ab (optional)" />
              </div>

              <div class="col-span-12 md:col-span-4">
                <.input field={@form[:decommission_date]} type="date" label="Nutzung bis (optional)" />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <.inputs_for :let={email} field={@form[:emails]}>
                <.live_component
                  module={SportywebWeb.PolymorphicLive.EmailFormComponent}
                  id={"email_#{email.index}"}
                  email={email}
                />
              </.inputs_for>

              <.inputs_for :let={phone} field={@form[:phones]}>
                <.live_component
                  module={SportywebWeb.PolymorphicLive.PhoneFormComponent}
                  id={"phone_#{phone.index}"}
                  phone={phone}
                />
              </.inputs_for>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12">
                <.label>Notizen (optional)</.label>
                <.inputs_for :let={note} field={@form[:notes]}>
                  <.input field={note[:content]} type="textarea" />
                </.inputs_for>
              </div>
            </.input_grid>
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
            </div>
            <.button
                :if={@equipment.id}
                class="bg-rose-700 hover:bg-rose-800"
                phx-click={JS.push("delete", value: %{id: @equipment.id})}
                data-confirm="Unwiderruflich löschen?">
                Löschen
              </.button>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def update(%{equipment: equipment} = assigns, socket) do
    changeset = Asset.change_equipment(equipment)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"equipment" => equipment_params}, socket) do
    changeset =
      socket.assigns.equipment
      |> Asset.change_equipment(equipment_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"equipment" => equipment_params}, socket) do
    save_equipment(socket, socket.assigns.action, equipment_params)
  end

  defp save_equipment(socket, :edit, equipment_params) do
    case Asset.update_equipment(socket.assigns.equipment, equipment_params) do
      {:ok, _equipment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Equipment erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_equipment(socket, :new, equipment_params) do
    equipment_params = Enum.into(equipment_params, %{
      "venue_id" => socket.assigns.equipment.venue.id
    })

    case Asset.create_equipment(equipment_params) do
      {:ok, _equipment} ->
        {:noreply,
         socket
         |> put_flash(:info, "Equipment erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
