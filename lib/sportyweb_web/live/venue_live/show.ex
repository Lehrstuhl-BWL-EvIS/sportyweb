defmodule SportywebWeb.VenueLive.Show do
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
    venue = Asset.get_venue!(id, [:club, :emails, :equipment, :fees, :notes, :phones])

    {:noreply,
     socket
     |> assign(:page_title, "Standort: #{venue.name}")
     |> assign(:venue, venue)
     |> assign(:club, venue.club)
     |> stream(:equipment, venue.equipment)}
  end
end
