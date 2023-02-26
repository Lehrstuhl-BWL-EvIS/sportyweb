defmodule Sportyweb.RBAC do
  @moduledoc """
  The RBAC context.
  """

  alias Sportyweb.Organization
  alias Sportyweb.RBAC.Role
  alias Sportyweb.RBAC.UserRole

  @doc """
  Returns the list of role structs of a club.

  ## Examples

      iex> list_roles(club_id)
      [%Role{}, ...]

  """
  def list_roles(club_id) do
    sort = Sportyweb.RBAC.Role.RolePermissionMatrix.get_role_names(:club)


    user_with_clubroles = club_id
    |> UserRole.list_clubs_userclubroles()
    |> Enum.reduce(%{}, fn x, acc ->
        Map.merge(acc, %{x.user => [x]}, fn _k, roles, role -> roles ++ role end)
      end)
    |> Enum.to_list()
    |> Enum.map(fn {user, clubroles} ->
        %Role{
          id: user.id,
          name: user.email,
          clubroles: clubroles
            |> Enum.map(&(&1.clubrole.name))
            |> Enum.sort(&(Enum.find_index(sort, fn x -> x == &1 end) <= Enum.find_index(sort, fn x -> x == &2 end)))
            |> Enum.join(", "),
          departmentroles: club_id
            |> Organization.list_departments()
            |> Enum.map(&(UserRole.list_users_departmentroles_in_a_department(user.id, &1.id)))
            |> List.flatten()
            |> Enum.map(&("#{&1.departmentrole.name} #{&1.department.name}"))
            |> Enum.sort(&(&1 <= &2))
            |> Enum.join(", ")
        }
      end)

    user_without_clubroles = club_id
    |> Organization.list_departments()
    |> Enum.map(&(UserRole.list_userdepartmentroles_by_department(&1.id)))
    |> List.flatten()
    |> Enum.reduce([], fn udr, acc -> if Enum.member?(user_with_clubroles |> Enum.map(&(&1.id)), udr.user_id), do: acc, else: acc ++ [udr] end)
    |> Enum.reduce(%{}, fn x, acc ->
        Map.merge(acc, %{x.user => [x]}, fn _k, roles, role -> roles ++ role end)
      end)
    |> Enum.to_list()
    |> Enum.map(fn {user, udr} ->
      %Role{
        id: user.id,
        name: user.email,
        clubroles: "",
        departmentroles: udr
          |> Enum.map(&("#{&1.departmentrole.name} #{&1.department.name}"))
          |> Enum.sort(&(&1 <= &2))
          |> Enum.join(", ")
      }
    end)

    user_with_clubroles ++ user_without_clubroles
  end
end
