defmodule SportywebWeb.EventLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :calendar)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    event =
      Calendar.get_event!(id, [
        :club,
        :emails,
        :notes,
        :phones,
        :postal_addresses,
        :locations,
        fees: :internal_events
      ])

    {:noreply,
     socket
     |> assign(:page_title, "Veranstaltung: #{event.name}")
     |> assign(:event, event)
     |> assign(:club, event.club)}
  end
end
