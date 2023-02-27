defmodule Sportyweb.RBAC.Role.RolePermissionMatrix do

  def role_permission_matrix(:application) do
    [
      admin: %{
        Name:                   "Sportyweb Administration",
      },

      tester: %{
        Name:                   "Tester",
      }
    ]
  end

  def role_permission_matrix(:club) do
    [
      club_admin: %{
        Name:                   "Vereins Administration",
        ClubLive:               [:edit],
        DepartmentLive:         [:index, :new, :edit, :show],
        HouseholdLive:          [:index, :new, :edit, :show],
        RoleLive:               [:index, :new, :edit, :show],
        Info:                   "verfügt über alle Zugriffsrechte im Kontext des zugrunde liegenden Vereins."
      },

      vorstand: %{
        Name:                   "Vorstand",
        ClubLive:               [:edit],
        DepartmentLive:         [:show],
        HouseholdLive:          [:index, :show],
        RoleLive:               [:index, :show],
        Info:                   "verfügt über die notwendigen Berechtigungen, sich die Inhalte aller Bereiche anzeigen zu lassen und die des Vereins zudem zu editieren."
      },

      mitarbeiter_rollen: %{
        Name:                   "Mitarbeiter- & Rollenverwaltung",
        RoleLive:               [:index, :new, :edit, :show],
        Info:                   "verfügt über die Berechtigungen, sich die Rollen der Nutzer eines Vereins anzeigen zu lassen sowie diese zu bearbeiten."

      },

      mitglieder_verwaltung: %{
        Name:                   "Mitgliederverwaltung",
        HouseholdLive:          [:index, :new, :edit, :show],
        Info:                   "verfügt über die Berechtigungen, sich die Mitglieder eines Vereins anzeigen zu lassen sowie diese zu bearbeiten."
      },

      anlagen_geraete_verwaltung: %{
        Name:                   "Anlagen- & Geräteverwaltung",
        Info:                   "verfügt über die Berechtigungen, sich die Anlagen und Geräte eines Vereins anzeigen zu lassen sowie diese zu bearbeiten."
      },

      finanz_verwaltung: %{
        Name:                   "Finanzverwaltung",
        Info:                   "verfügt über die Berechtigungen, sich die Finanzen eines Vereins anzeigen zu lassen sowie diese zu bearbeiten."
      },

      pr: %{
        Name:                   "Öffentlichkeitsarbeit",
        Info:                   "verfügt über die Berechtigungen, sich die relevanten Inhalte im Kontext der Öffentlichkeitsarbeit eines Vereins anzeigen zu lassen sowie diese zu bearbeiten."
      }
    ]
  end

  def role_permission_matrix(:department) do
    [
      abteilungsleiter: %{
        Name:                   "Abteilungsleiter",
        DepartmentLive:         [:edit],
        Info:                   "verfügt über die Berechtigungen, sich eine Abteilung eines Vereins anzeigen zu lassen sowie diese zu bearbeiten."
      },

      trainer: %{
        Name:                   "Trainer",
        Info:                   "verfügt über die Berechtigungen, sich eine Abteilung eines Vereins anzeigen zu lassen sowie trainingsrelevante Inhalte darin zu bearbeiten."
      },

      wettampfverwaltung: %{
        Name:                   "Wettkampfverwaltung",
        Info:                   "verfügt über die Berechtigungen, sich eine Abteilung eines Vereins anzeigen zu lassen sowie wettkampfsrelevante Inhalte darin zu bearbeiten."
      },

      abteilungsmitglied: %{
        Name:                   "Abteilungsmitglied",
        Info:                   "verfügt über die Berechtigungen, sich eine Abteilung eines Vereins anzeigen zu lassen."
      }
    ]
  end

  def basic_permissions_when_associated_to_club(currentpermissions, true, :ClubLive), do: currentpermissions ++ [:show]
  def basic_permissions_when_associated_to_club(currentpermissions, true, :DepartmentLive), do: currentpermissions ++ [:index]
  def basic_permissions_when_associated_to_club(currentpermissions, _false, _view), do: currentpermissions

  def basic_permissions_when_associated_to_department(currentpermissions, true, :DepartmentLive), do: currentpermissions ++ [:show]
  def basic_permissions_when_associated_to_department(currentpermissions, _false, _view), do: currentpermissions

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
