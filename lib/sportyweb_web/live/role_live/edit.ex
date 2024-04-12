defmodule SportywebWeb.RoleLive.Edit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Accounts
  alias Sportyweb.RBAC
  alias Sportyweb.RBAC.Role
  alias Sportyweb.RBAC.UserRole

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :authorization)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"user_id" => user_id, "club_id" => club_id}) do
    assigned_club_roles = list_users_assigned_club_roles(user_id, club_id)
    available_club_roles = list_users_available_club_roles(assigned_club_roles)

    assigned_department_roles = list_users_assigned_department_roles(user_id, club_id)

    availabe_department_roles =
      list_users_available_department_roles(club_id, assigned_department_roles)

    socket
    |> assign(:user, get_user(user_id))
    |> assign(:club, get_club(club_id))
    |> assign(:assigned_club_roles, assigned_club_roles)
    |> assign(:available_club_roles, available_club_roles)
    |> assign(:assigned_department_roles, assigned_department_roles)
    |> assign(:availabe_department_roles, availabe_department_roles)
    |> assign(:refresh_path, refresh_path(user_id, club_id))
  end

  @impl true
  def handle_event("delete", %{"club_id" => id}, socket) do
    ucr = UserRole.get_user_club_role!(id)
    {:ok, _} = UserRole.delete_user_club_role(ucr)

    {:noreply,
     socket
     |> put_flash(:info, "Die Rolle wurde erfolgreich vom Nutzer entfernt.")
     |> push_navigate(to: socket.assigns.refresh_path)}
  end

  def handle_event(
        "delete",
        %{"department_id" => department_id, "departmentrole_id" => departmentrole_id},
        socket
      ) do
    udr =
      UserRole.get_user_department_role_by_references(
        socket.assigns.user.id,
        department_id,
        departmentrole_id
      )

    {:ok, _} = UserRole.delete_user_department_role(udr)

    {:noreply,
     socket
     |> put_flash(:info, "Die Rolle wurde erfolgreich vom Nutzer entfernt.")
     |> push_navigate(to: socket.assigns.refresh_path)}
  end

  def handle_event("add", %{"club_id" => id}, socket) do
    UserRole.create_user_club_role(%{
      user_id: socket.assigns.user.id,
      club_id: socket.assigns.club.id,
      clubrole_id: id
    })

    {:noreply,
     socket
     |> put_flash(:info, "Die Rolle wurde dem Nutzer erfolgreich hinzugefügt.")
     |> push_navigate(to: socket.assigns.refresh_path)}
  end

  def handle_event(
        "add",
        %{"department_id" => department_id, "departmentrole_id" => departmentrole_id},
        socket
      ) do
    UserRole.create_user_department_role(%{
      user_id: socket.assigns.user.id,
      department_id: department_id,
      departmentrole_id: departmentrole_id
    })

    {:noreply,
     socket
     |> put_flash(:info, "Die Rolle wurde dem Nutzer erfolgreich hinzugefügt.")
     |> push_navigate(to: socket.assigns.refresh_path)}
  end

  defp get_user(id), do: Accounts.get_user!(id)
  defp get_club(id), do: Organization.get_club!(id)

  defp list_users_assigned_club_roles(user_id, club_id),
    do: UserRole.list_users_clubroles_in_a_club(user_id, club_id)

  defp list_users_available_club_roles(ucrs),
    do: RBAC.Role.list_clubroles() -- Enum.map(ucrs, & &1.clubrole)

  defp list_users_assigned_department_roles(user_id, club_id) do
    club_id
    |> Organization.list_departments()
    |> Enum.map(& &1.id)
    |> Enum.map(&UserRole.list_users_departmentroles_in_a_department(user_id, &1))
    |> List.flatten()
    |> Enum.map(
      &%Role.SubRoleDepartment{
        id: &1.department_id,
        departmentrole_id: &1.departmentrole_id,
        name: "#{&1.departmentrole.name} #{&1.department.name}"
      }
    )
    |> Enum.sort(&(&1.name <= &2.name))
  end

  defp list_users_available_department_roles(club_id, assigned_department_roles) do
    club_id
    |> Organization.list_departments()
    |> Enum.map(fn department ->
      Role.list_departmentroles()
      |> Enum.map(
        &%Role.SubRoleDepartment{
          id: department.id,
          departmentrole_id: &1.id,
          name: "#{&1.name} #{department.name}"
        }
      )
    end)
    |> List.flatten()
    |> Kernel.--(assigned_department_roles)
    |> Enum.sort(&(&1.name <= &2.name))
  end

  defp refresh_path(user_id, club_id), do: ~p"/clubs/#{club_id}/roles/#{user_id}/edit"
end
