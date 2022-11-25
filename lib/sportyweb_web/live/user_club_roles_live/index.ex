defmodule SportywebWeb.UserClubRolesLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.AccessControl
  alias Sportyweb.AccessControl.UserClubRoles

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :userclubroles, list_userclubroles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User club roles")
    |> assign(:user_club_roles, AccessControl.get_user_club_roles!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User club roles")
    |> assign(:user_club_roles, %UserClubRoles{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Userclubroles")
    |> assign(:user_club_roles, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_club_roles = AccessControl.get_user_club_roles!(id)
    {:ok, _} = AccessControl.delete_user_club_roles(user_club_roles)

    {:noreply, assign(socket, :userclubroles, list_userclubroles())}
  end

  defp list_userclubroles do
    AccessControl.list_userclubroles()
  end
end
