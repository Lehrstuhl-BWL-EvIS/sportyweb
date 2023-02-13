defmodule Sportyweb.RBAC.Policy do

  use SportywebWeb, :verified_routes

  alias Sportyweb.Organization

  alias Sportyweb.RBAC.UserRole
  alias Sportyweb.RBAC.Role.RolePermissionMatrix, as: RPM

  def on_mount(:permissions, params, _session, socket) do
    #user = socket.assigns.current_user.email |> String.split("@") |> Enum.at(0)
    action = socket.assigns.live_action
    view = get_live_view(socket.view)
    #dbg([user, action, view, params])
    #IO.inspect([user, action, view, params])

    if permit?(socket.assigns.current_user, action, view, params) do
      {:cont, socket}
    else
      {:halt,
        socket
        |> Phoenix.LiveView.put_flash(:error, "Zugriff verweigert.")
        |> Phoenix.LiveView.redirect(to: error_redirect(action, view, params))}
    end
  end

  defp permit?(_user, :index, :ClubLive, _params), do: true
  defp permit?(_user, :new, :ClubLive, _params), do: false
  defp permit?(user, action, :ClubLive, %{"id" => club_id}), do: is_allowed?(user.id, action, club_id, :ClubLive)

  defp permit?(user, action, :DepartmentLive, params) do
    club_id = if Map.has_key?(params, "club_id"), do: params["club_id"], else: params["id"] |> Organization.get_department!() |> Map.get(:club_id)
    is_allowed?(user.id, action, club_id, :DepartmentLive)
  end

  defp permit?(user, action, :UserClubRoleLive, %{"club_id" => club_id}), do: is_allowed?(user.id, action, club_id, :UserClubRoleLive)


  defp get_live_view(view), do: view |> Kernel.inspect() |> String.split(".") |> Enum.at(1) |> String.to_existing_atom()
  defp list_user_clubroles_in_club(user_id, club_id) do
    user_id
    |> UserRole.list_users_clubroles_in_a_club(club_id)
    |> Enum.map(&(&1.clubrole.name))
    |> Enum.map(&(String.downcase(&1)))
    |> Enum.map(&(String.replace(&1, " ", "_")))
    |> Enum.map(&(String.to_existing_atom(&1)))
  end

  defp is_allowed?(user_id, action, club_id, view) do
    user_roles = list_user_clubroles_in_club(user_id, club_id)
    permissions = RPM.role_permission_matrix(:club)

    user_roles
    |> Enum.reduce([], fn x, acc -> acc ++ Keyword.get_values(permissions, x) end)
    |> Enum.map(&(Map.get(&1, view)))
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.member?(action)
  end

  defp error_redirect(:new, :ClubLive, _params), do: ~p"/clubs"
  defp error_redirect(_action, :ClubLive, %{"id" => club_id}), do: ~p"/clubs/#{club_id}"
  defp error_redirect(_action, :DepartmentLive, %{"club_id" => club_id}), do: ~p"/clubs/#{club_id}"
  defp error_redirect(_action, :DepartmentLive, %{"id" => dept_id}), do: ~p"/clubs/#{dept_id |> Organization.get_department!() |> Map.get(:club_id)}"
  defp error_redirect(_action, :UserClubRoleLive, %{"club_id" => club_id}), do: ~p"/clubs/#{club_id}"

end
