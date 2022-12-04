defmodule SportywebWeb.ClubLive.Userrolemanagement do
  use SportywebWeb, :live_view

  alias Sportyweb.AccessControl.PolicyClub

  alias Sportyweb.Organization

  @impl true
  def mount(%{"id" => club_id}, _session, socket) do
    if PolicyClub.can?(socket.assigns.current_user, :userrolemanagement, %{"id" => club_id}) do
      {:ok,
        socket
        |> assign(:club, Organization.get_club!(club_id))
        |> assign(:clubmembers, PolicyClub.get_club_members_and_their_roles(club_id))
        |> assign(:roles, ["club_subadmin", "club_member"])}
    else
      {:ok, socket
        |> put_flash(:error, "No permission to manage user roles of club members.")
        |> redirect(to: ~p"/clubs/#{club_id}")}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("role_selected", %{"role" => newrole}, socket) do
    {:noreply, socket}
  end
end
