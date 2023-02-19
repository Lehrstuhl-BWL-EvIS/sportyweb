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

  @doc """
  Gets a single role.

  Raises if the Role does not exist.

  ## Examples

      iex> get_role!(123)
      %Role{}

  """
  def get_role!(id), do: raise "TODO"

  @doc """
  Creates a role.

  ## Examples

      iex> create_role(%{field: value})
      {:ok, %Role{}}

      iex> create_role(%{field: bad_value})
      {:error, ...}

  """
  def create_role(attrs \\ %{}) do
    raise "TODO"
  end

  @doc """
  Updates a role.

  ## Examples

      iex> update_role(role, %{field: new_value})
      {:ok, %Role{}}

      iex> update_role(role, %{field: bad_value})
      {:error, ...}

  """
  def update_role(%Role{} = role, attrs) do
    raise "TODO"
  end

  @doc """
  Deletes a Role.

  ## Examples

      iex> delete_role(role)
      {:ok, %Role{}}

      iex> delete_role(role)
      {:error, ...}

  """
  def delete_role(%Role{} = role) do
    raise "TODO"
  end

  @doc """
  Returns a data structure for tracking role changes.

  ## Examples

      iex> change_role(role)
      %Todo{...}

  """
  def change_role(%Role{} = role, _attrs \\ %{}) do
    raise "TODO"
  end
end
