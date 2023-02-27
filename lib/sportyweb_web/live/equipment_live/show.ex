defmodule SportywebWeb.EquipmentLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
    socket
    |> assign(:club_navigation_current_item, :assets)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    equipment = Asset.get_equipment!(id, [venue: :club])

    {:noreply,
     socket
     |> assign(:page_title, "Equipment: #{equipment.name}")
     |> assign(:equipment, equipment)
     |> assign(:venue, equipment.venue)
     |> assign(:club, equipment.venue.club)}
  end
end
