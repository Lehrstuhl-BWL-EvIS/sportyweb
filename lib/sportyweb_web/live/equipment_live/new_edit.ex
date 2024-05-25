defmodule SportywebWeb.EquipmentLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset
  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.EquipmentLive.FormComponent}
        id={@equipment.id || :new}
        title={@page_title}
        action={@live_action}
        equipment={@equipment}
        navigate={
          if @equipment.id, do: ~p"/equipment/#{@equipment}", else: ~p"/locations/#{@location}"
        }
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :assets)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    equipment = Asset.get_equipment!(id, [:emails, :phones, :notes, location: :club])

    socket
    |> assign(:page_title, "Equipment bearbeiten")
    |> assign(:equipment, equipment)
    |> assign(:location, equipment.location)
    |> assign(:club, equipment.location.club)
  end

  defp apply_action(socket, :new, %{"location_id" => location_id}) do
    location = Asset.get_location!(location_id, [:club])

    socket
    |> assign(:page_title, "Equipment erstellen")
    |> assign(:equipment, %Equipment{
      location_id: location.id,
      location: location,
      emails: [%Email{}],
      phones: [%Phone{}],
      notes: [%Note{}]
    })
    |> assign(:location, location)
    |> assign(:club, location.club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    equipment = Asset.get_equipment!(id)
    {:ok, _} = Asset.delete_equipment(equipment)

    {:noreply,
     socket
     |> put_flash(:info, "Equipment erfolgreich gelöscht")
     |> push_navigate(to: "/locations/#{equipment.location_id}")}
  end
end
