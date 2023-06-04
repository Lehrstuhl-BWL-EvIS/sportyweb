defmodule SportywebWeb.VenueLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset
  alias Sportyweb.Asset.Venue
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
        module={SportywebWeb.VenueLive.FormComponent}
        id={@venue.id || :new}
        title={@page_title}
        action={@live_action}
        venue={@venue}
        navigate={if @venue.id, do: ~p"/venues/#{@venue}", else: ~p"/clubs/#{@club}/venues"}
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
    venue = Asset.get_venue!(id, [:club, :emails, :phones, :postal_addresses, :notes])

    socket
    |> assign(:page_title, "Standort bearbeiten")
    |> assign(:venue, venue)
    |> assign(:club, venue.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Standort erstellen")
    |> assign(:venue, %Venue{
      club_id: club.id,
      club: club,
      postal_addresses: [%PostalAddress{}],
      emails: [%Email{}],
      phones: [%Phone{}],
      notes: [%Note{}]}
    )
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    venue = Asset.get_venue!(id)
    {:ok, _} = Asset.delete_venue(venue)

    {:noreply,
     socket
     |> put_flash(:info, "Standort erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{venue.club_id}/venues")}
  end
end
