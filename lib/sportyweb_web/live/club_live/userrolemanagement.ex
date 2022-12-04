defmodule SportywebWeb.ClubLive.Userrolemanagement do
  use SportywebWeb, :live_view

  alias Sportyweb.AccessControl.PolicyClub

  alias Sportyweb.Organization

  @impl true
  def mount(%{"id" => club_id}, _session, socket) do
      {:ok,
        socket
        |> assign(:club, Organization.get_club!(club_id))
        |> assign(:clubmembers, PolicyClub.get_club_members_and_their_roles(club_id))
        |> assign(:roles, ["club_subadmin", "club_readwrite_member", "club_member"])}
  end

  @impl true
  def handle_params(%{"id" => club_id}, _, socket) do
    if PolicyClub.can?(socket.assigns.current_user, socket.assigns.live_action, %{"id" => club_id}) do
      {:noreply, socket}
    else
      {:noreply, socket
        |> put_flash(:error, "No permission to manage user roles of club members.")
        |> redirect(to: ~p"/clubs/#{club_id}")}
    end
  end

  @impl true
  def handle_event("role_selected", %{"role" => newrole}, socket) do #TODO
    {:noreply, socket}
  end
end
