defmodule SportywebWeb.EventLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset.Venue
  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event
  alias Sportyweb.Organization
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone
  alias Sportyweb.Polymorphic.PostalAddress

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.EventLive.FormComponent}
        id={@event.id || :new}
        title={@page_title}
        action={@live_action}
        event={@event}
        navigate={if @event.id, do: ~p"/events/#{@event}", else: ~p"/clubs/#{@event.club}/events"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:club_navigation_current_item, :calendar)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    event = Calendar.get_event!(id, [:club, :emails, :phones, :postal_addresses, :notes, :venues])

    socket
    |> assign(:page_title, "Veranstaltung bearbeiten")
    |> assign(:event, event)
    |> assign(:club, event.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Veranstaltung erstellen")
    |> assign(:event, %Event{
      club_id: club.id,
      club: club,
      venues: [%Venue{}],
      postal_addresses: [%PostalAddress{}],
      emails: [%Email{}],
      phones: [%Phone{}],
      notes: [%Note{}]}
    )
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Calendar.get_event!(id)
    {:ok, _} = Calendar.delete_event(event)

    {:noreply,
      socket
      |> put_flash(:info, "Veranstaltung erfolgreich gelöscht")
      |> push_navigate(to: "/clubs/#{event.club_id}/events")}
  end
end
