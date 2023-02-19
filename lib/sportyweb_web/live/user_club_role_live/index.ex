defmodule SportywebWeb.UserClubRoleLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.RBAC.UserRole

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :userclubroles, list_userclubroles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Userclubroles")
    |> assign(:user_club_role, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_club_role = UserRole.get_user_club_role!(id)
    {:ok, _} = UserRole.delete_user_club_role(user_club_role)

    {:noreply, assign(socket, :userclubroles, list_userclubroles())}
  end

  defp list_userclubroles do
    UserRole.list_userclubroles()
  end
end
