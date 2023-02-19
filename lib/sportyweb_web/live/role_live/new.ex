defmodule SportywebWeb.RoleLive.New do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounts
  alias Sportyweb.Organization
  alias Sportyweb.RBAC.UserRole

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:club_navigation_current_item, :authorization)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    users = list_visible_users() -- list_users_in_a_club(club_id)

    socket
    |> assign(:users, users |> Enum.sort())
    |> assign(:club, Organization.get_club!(club_id))
  end

  defp list_visible_users(), do:  Accounts.list_all_users
  defp list_users_in_a_club(club_id), do: club_id |> UserRole.list_users_in_a_club() |> Enum.map(&(&1.user))
end
