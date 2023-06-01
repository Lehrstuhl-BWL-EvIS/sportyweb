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
    event = Calendar.get_event!(id, [:club, :emails, :fees, :notes, :phones, :postal_addresses, :venues])

    {:noreply,
     socket
     |> assign(:page_title, "Veranstaltung: #{event.name}")
     |> assign(:event, event)
     |> assign(:club, event.club)}
  end
end
