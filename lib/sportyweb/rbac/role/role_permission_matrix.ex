defmodule Sportyweb.RBAC.Role.RolePermissionMatrix do

  def role_permission_matrix(:application) do
    [
      sportyweb_administrator: []
    ]
  end

  def role_permission_matrix(:club) do
    [
      club_admin: %{
        Name:                   "Vereins Administration",
        ClubLive:               [:edit],
        DepartmentLive:         [:index, :new, :edit, :show],
        HouseholdLive:          [:index, :new, :edit, :show],
        UserClubRoleLive:       [:index, :new, :edit, :show]
      },

      vorstand: %{
        Name:                   "Vorstand",
        ClubLive:               [:edit],
        DepartmentLive:         [:show],
        HouseholdLive:          [:index, :show],
        UserClubRoleLive:       [:index]
      },

      mitarbeiter_rollen: %{
        Name:                   "TEST Mitarbeiter- & Rollenverwaltung",
        UserClubRoleLive:       [:index, :new, :edit, :show]
      },

      mitglieder_verwaltung: %{
        Name:                   "Mitgliederverwaltung",
        HouseholdLive:          [:index, :new, :edit, :show],
      },

      anlagen_geraete_verwaltung: %{
        Name:                   "Anlagen- & Geräteverwaltung",
      },

      finanz_verwaltung: %{
        Name:                   "Finanzverwaltung",
      },

      pr: %{
        Name:                   "Öffentlichkeitsarbeit",
      },

      tester: %{
        Name:                   "Tester",
        ClubLive:               [:index, :new, :edit, :show],
        DepartmentLive:         [:index, :new, :edit, :show],
        HouseholdLive:          [:index, :new, :edit, :show],
        UserClubRoleLive:       [:index, :new, :edit, :show]
      }
    ]
  end

  def role_permission_matrix(:department) do
    [
      abteilungsleiter: %{
        Name:                   "Abteilungsleiter",
        DepartmentLive:         [:show, :edit]
      },

      trainer: %{
        Name:                   "Trainer",
        DepartmentLive:         [:show],
      },

      wettampfverwaltung: %{
        Name:                   "Wettkampfverwaltung",
        DepartmentLive:         [:show],
      },

      abteilungsmitglied: %{
        Name:                   "Abteilungsmitglied",
        DepartmentLive:         [:show],
      }
    ]
  end

  def basic_permissions_when_associated_to_club(currentpermissions, true, :ClubLive), do: currentpermissions ++ [:show]
  def basic_permissions_when_associated_to_club(currentpermissions, true, :DepartmentLive), do: currentpermissions ++ [:index]
  def basic_permissions_when_associated_to_club(currentpermissions, _false, _view), do: currentpermissions

  def get_role_names(atom) do
    atom
    |> role_permission_matrix()
    |> Keyword.values()
    |> Enum.map(&((Map.get(&1, :Name))))
  end

  def to_role_atom(atom, role) do
    atom
    |> role_permission_matrix()
    |> Enum.filter(fn {_key, value} -> Map.get(value, :Name) == role end)
    |> Keyword.keys()
    |> Enum.at(0)
  end
end
