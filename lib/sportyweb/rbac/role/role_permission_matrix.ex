defmodule Sportyweb.RBAC.Role.RolePermissionMatrix do

  def role_permission_matrix(:application) do
    [
      sportyweb_administrator: []
    ]
  end

  def role_permission_matrix(:club) do
    [
      vereins_administrator: %{
        ClubLive:               [:index, :edit, :show],
        DepartmentLive:         [:index, :new, :edit, :show],
        HouseholdLive:          [:index, :new, :edit, :show]
      },

      vorstand: %{
        ClubLive:               [:index, :edit, :show],
        DepartmentLive:         [:index, :show],
        HouseholdLive:          [:index, :show]
      }
    ]
  end

  def get_roles(atom) when is_atom(atom) do
    atom
    |> role_permission_matrix()
    |> Keyword.keys()
    |> Enum.map(&(Atom.to_string(&1)))
    |> Enum.map(&(rename_roles(&1)))
  end

  defp rename_roles(role) do
    role
    |> String.split("_")
    |> Enum.map_join(" ", &(String.capitalize(&1)))
  end

end
