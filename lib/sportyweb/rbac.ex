defmodule Sportyweb.RBAC do
  @moduledoc """
  The RBAC context.
  """

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

    club_id
    |> UserRole.list_clubs_userclubroles()
    |> Enum.reduce(%{}, fn x, acc ->
        Map.merge(acc, %{x.user => [x]}, fn _k, roles, role -> roles ++ role end)
      end)
    |> Enum.to_list()
    |> Enum.map(fn {key, value} ->
        %Role{
          id: key.id,
          name: key.email,
          roles: value
            |> Enum.map(fn x -> x.clubrole.name end)
            |> Enum.sort(&(Enum.find_index(sort, fn x -> x == &1 end) <= Enum.find_index(sort, fn x -> x == &2 end)))
            |> Enum.join(", ")
        }
      end)
  end
end
