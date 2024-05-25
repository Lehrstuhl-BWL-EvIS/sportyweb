defmodule SportywebWeb.LocationLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset
  alias Sportyweb.Organization.Club

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :assets)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    location =
      Asset.get_location!(id, [
        :club,
        :emails,
        :equipment,
        :notes,
        :phones,
        :postal_addresses,
        fees: :internal_events
      ])

    {:noreply,
     socket
     |> assign(:page_title, "Standort: #{location.name}")
     |> assign(:location, location)
     |> assign(:club, location.club)
     |> stream(:equipment, location.equipment)}
  end
end
