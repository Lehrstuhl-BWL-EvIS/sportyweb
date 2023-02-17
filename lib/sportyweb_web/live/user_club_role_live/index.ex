defmodule SportywebWeb.UserClubRoleLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization

  alias Sportyweb.RBAC.UserRole
  alias Sportyweb.RBAC.UserRole.UserClubRole

  defmodule RoleAdministration do
    defstruct [:id, :email, :roles]
  end

  @impl true
  def mount(_params, _session, socket) do

    {:ok,
      socket
      |> assign(:club_navigation_current_item, :authorization)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User club role")
    |> assign(:user_club_role, UserRole.get_user_club_role!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User club role")
    |> assign(:user_club_role, %UserClubRole{})
  end

  defp apply_action(socket, :index, %{"club_id" => club_id} = params) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Listing Userclubroles")
    |> assign(:user_club_role, nil)
    |> assign(:club, club)
    |> assign(:userclubroles, list_role_administration(list_userclubroles(params)))
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

  defp list_userclubroles(%{"club_id" => club_id}) do
    UserRole.list_clubs_userclubroles(club_id)
  end

  defp list_role_administration(list_of_ucrs) do
    sort = Sportyweb.RBAC.Role.RolePermissionMatrix.get_role_names(:club)

    list_of_ucrs
    |> Enum.reduce(%{}, fn x, acc ->
        Map.merge(acc, %{x.user => [x]}, fn _k, roles, role -> roles ++ role end)
      end)
    |> Enum.to_list()
    |> Enum.map(fn {key, value} ->
        %RoleAdministration{
          id: key.id,
          email: key.email,
          roles: value
            |> Enum.map(fn x -> x.clubrole.name end)
            |> Enum.sort(&(Enum.find_index(sort, fn x -> x == &1 end) <= Enum.find_index(sort, fn x -> x == &2 end)))
            |> Enum.join(", ")
        }
      end)
  end
end
