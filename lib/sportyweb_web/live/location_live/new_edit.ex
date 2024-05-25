defmodule SportywebWeb.LocationLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset
  alias Sportyweb.Asset.Location
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
        module={SportywebWeb.LocationLive.FormComponent}
        id={@location.id || :new}
        title={@page_title}
        action={@live_action}
        location={@location}
        navigate={
          if @location.id, do: ~p"/locations/#{@location}", else: ~p"/clubs/#{@club}/locations"
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
    location = Asset.get_location!(id, [:club, :emails, :phones, :postal_addresses, :notes])

    socket
    |> assign(:page_title, "Standort bearbeiten")
    |> assign(:location, location)
    |> assign(:club, location.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Standort erstellen")
    |> assign(:location, %Location{
      club_id: club.id,
      club: club,
      postal_addresses: [%PostalAddress{}],
      emails: [%Email{}],
      phones: [%Phone{}],
      notes: [%Note{}]
    })
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    location = Asset.get_location!(id)
    {:ok, _} = Asset.delete_location(location)

    {:noreply,
     socket
     |> put_flash(:info, "Standort erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{location.club_id}/locations")}
  end
end
