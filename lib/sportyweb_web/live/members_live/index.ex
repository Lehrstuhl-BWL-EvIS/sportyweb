defmodule SportywebWeb.MembersLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Personal

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :members)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index_root, _params) do
    socket
    |> redirect(to: "/clubs")
  end

  defp apply_action(socket, :index, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id);
    contacts = Personal.list_contacts_of_members(club_id,  [:postal_addresses, :emails, :phones, memberships: [:group, :department, :club ]])

    socket
    |> assign(:page_title, "Mitgliedschaften")
    |> assign(:club, club)
    |> stream(:contacts, contacts)
  end
end
