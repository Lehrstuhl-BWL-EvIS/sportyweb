defmodule SportywebWeb.UserClubRoleLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Accounts
  alias Sportyweb.RBAC
  alias Sportyweb.RBAC.UserRole

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:club_navigation_current_item, :authorization)}
  end

  @impl true
  def handle_params(%{"user_id" => user_id, "club_id" => club_id}, _url, socket) do
    ucrs = list_users_clubroles(user_id, club_id)
    open_clubroles = list_open_clubroles(ucrs)

    {:noreply,
      socket
      |> assign(:user, get_user(user_id))
      |> assign(:club, get_club(club_id))
      |> assign(:userclubroles, ucrs)
      |> assign(:open_clubroles, open_clubroles)
      |> assign(:refresh_path, refresh_path(user_id, club_id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ucr = UserRole.get_user_club_role!(id)
    {:ok, _} = UserRole.delete_user_club_role(ucr)

    {:noreply,
      socket
      |> put_flash(:info, "Die Rolle wurde erfolgreich vom Nutzer entfernt.")
      |> push_navigate(to: socket.assigns.refresh_path)}
  end

  def handle_event("add", %{"id" => id}, socket) do
    UserRole.create_user_club_role(%{user_id: socket.assigns.user.id, club_id: socket.assigns.club.id, clubrole_id: id})

    {:noreply,
      socket
      |> put_flash(:info, "Die Rolle wurde dem Nutzer erfolgreich hinzugefügt.")
      |> push_navigate(to: socket.assigns.refresh_path)}
  end

  defp get_user(id), do: Accounts.get_user!(id)
  defp get_club(id), do: Organization.get_club!(id)

  defp list_users_clubroles(user_id, club_id), do: UserRole.list_users_clubroles_in_a_club(user_id, club_id)
  defp list_open_clubroles(ucrs), do: RBAC.Role.list_clubroles() -- Enum.map(ucrs, &(&1.clubrole))

  defp refresh_path(user_id, club_id), do: ~p"/clubs/#{club_id}/userclubroles/#{user_id}"

end
