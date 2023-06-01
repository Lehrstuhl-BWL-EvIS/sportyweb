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
        navigate={if @equipment.id, do: ~p"/equipment/#{@equipment}", else: ~p"/venues/#{@venue}"}
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
    equipment = Asset.get_equipment!(id, [:emails, :phones, :notes, venue: :club])

    socket
     |> assign(:page_title, "Equipment bearbeiten")
     |> assign(:equipment, equipment)
     |> assign(:venue, equipment.venue)
     |> assign(:club, equipment.venue.club)
  end

  defp apply_action(socket, :new, %{"venue_id" => venue_id}) do
    venue = Asset.get_venue!(venue_id, [:club])

    socket
    |> assign(:page_title, "Equipment erstellen")
    |> assign(:equipment, %Equipment{
      venue_id: venue.id,
      venue: venue,
      emails: [%Email{}],
      phones: [%Phone{}],
      notes: [%Note{}]}
    )
    |> assign(:venue, venue)
    |> assign(:club, venue.club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    equipment = Asset.get_equipment!(id)
    {:ok, _} = Asset.delete_equipment(equipment)

    {:noreply,
     socket
     |> put_flash(:info, "Equipment erfolgreich gelöscht")
     |> push_navigate(to: "/venues/#{equipment.venue_id}")}
  end
end
