defmodule Sportyweb.RBAC.Role.RolePermissionMatrix do
  def role_permission_matrix(:application) do
    [
      admin: %{
        Name: "Sportyweb Administration",
        Info: "verfügt über alle Zugriffsrechte in der Anwendung."
      },
      tester: %{
        Name: "Tester",
        Info: "nur für automatische Tests."
      }
    ]
  end

  def role_permission_matrix(:club) do
    [
      verein_admin: %{
        Name: "Vereinsadministration",
        Info:
          "verfügt über die vollen lesenden und schreibenden Zugriffe auf alle Ressourcen und Operationen im jeweiligen Verein.",
        ClubLive: [:edit],
        RoleLive: [:index, :new, :edit, :show],
        EventLive: [:index, :new, :edit, :show],
        DepartmentLive: [:index, :new, :edit, :show],
        GroupLive: [:index, :new, :edit, :show],
        ContactLive: [:index, :new, :edit, :show],
        LocationLive: [:index, :new, :edit, :show],
        EquipmentLive: [:index, :new, :edit, :show],
        FeeLive: [:index, :new, :edit, :show]
      },
      verein_lead: %{
        Name: "Geschäftsführung",
        Info:
          "verfügt über die vollen lesenden und schreibenden Zugriffe auf alle Ressourcen und Operationen, die im Kontext der Vereinsführung stehen. Dabei wird primär auf die Themenbereiche Vereinsverwaltung, Finanzen, Kommunikation und Sponsoring abgestellt. Für alle anderen Inhalte sind lediglich Leserechte gewährt.",
        ClubLive: [:edit],
        RoleLive: [:index, :new, :edit, :show],
        EventLive: [:index, :show],
        DepartmentLive: [:index, :new, :show],
        GroupLive: [:index, :new, :show],
        ContactLive: [:index, :new, :edit, :show],
        LocationLive: [:index, :show],
        EquipmentLive: [:index, :show],
        FeeLive: [:index, :new, :edit, :show]
      },
      rollen_verwaltung: %{
        Name: "Rollenverwaltung",
        Info:
          "verfügt über die notwendigen Zugriffe, um Nutzern im Verein Rollen zuweisen und entziehen zu können.",
        RoleLive: [:index, :new, :edit, :show]
      },
      vereins_mitglied: %{
        Name: "Vereinsmitglied",
        Info:
          "verügt über die notwendigen Zugriffe Vereins- und Abteilungsinformationen und -angebote einzusehen, die sich an alle Mitglieder richten.",
        EventLive: [:index, :show],
        DepartmentLive: [:show],
        GroupLive: [:index]
      },
      finanz_verwaltung: %{
        Name: "Finanzverwaltung",
        Info:
          "verfügt über die notwendigen lesenden und schreibenden Zugriffe auf alle Ressourcen und Operationen, die im Kontext der Finanzverwaltung stehen.",
        FeeLive: [:index, :new, :edit, :show]
      },
      schiedsstelle: %{
        Name: "Schiedsstelle",
        Info:
          "verfügt über die notwendigen lesenden und schreibenden Zugriffe auf alle Ressourcen und Operationen, die im Kontext der Bearbeitung von Streitfällen stehen."
      },
      pr: %{
        Name: "Öffentlichkeitsarbeit",
        Info:
          "verfügt über die notwendigen lesenden und schreibenden Zugriffe auf alle Ressourcen und Operationen, die im Kontext der Öffentlichkeitsarbeit stehen.",
        ContactLive: [:index, :new, :edit, :show]
      },
      jugendleitung: %{
        Name: "Jugendleitung",
        Info:
          "verfügt über die notwendigen lesenden und schreibenden Zugriffe auf alle Ressourcen und Operationen, die im Kontext der Arbeit mit Jugendlichen stehen."
      },
      anlagen_geraete_verwaltung: %{
        Name: "Anlagen- & Geräteverwaltung",
        Info:
          "verfügt über die notwendigen lesenden und schreibenden Zugriffe auf alle Ressourcen und Operationen, die im Kontext der Verwaltung von Anlagen und Geräten des Vereins stehen.",
        LocationLive: [:index, :new, :edit, :show],
        EquipmentLive: [:index, :new, :edit, :show]
      },
      mitglieder_verwaltung: %{
        Name: "Mitgliederverwaltung",
        Info:
          "verfügt über die notwendigen lesenden und schreibenden Zugriffe auf alle Ressourcen und Operationen, die im Kontext der Verwaltung von Mitgliedern stehen.",
        ContactLive: [:index, :new, :edit, :show]
      }
    ]
  end

  def role_permission_matrix(:department) do
    [
      abteilungsleiter: %{
        Name: "Abteilungsleiter",
        Info:
          "verfügt über die notwendigen lesenden und schreibenden Zugriffe auf alle Ressourcen und Operationen innerhalb einer Abteilung.",
        DepartmentLive: [:edit],
        GroupLive: [:index, :new, :edit, :show]
      },
      trainer: %{
        Name: "Trainer",
        Info:
          "verfügt über die notwendigen lesenden und schreibenden Zugriffe auf alle Ressourcen und Operationen innerhalb der dedizierten Abteilung, die im Kontext der Trainings- und Übungsleitung stehen.",
        GroupLive: [:index, :edit, :show]
      },
      wettampfverwaltung: %{
        Name: "Wettkampfverwaltung",
        Info:
          "verfügt über die notwendigen lesenden und schreibenden Zugriffe auf alle Ressourcen und Operationen innerhalb der dedizierten Abteilung, die im Kontext des Wettkampf- und Ligabetriebs stehen.",
        GroupLive: [:index, :edit, :show]
      },
      abteilungsmitglied: %{
        Name: "Abteilungsmitglied",
        Info:
          "verfügt über die notwendigen Zugriffe Abteilungsinformationen und -angebote einzusehen, die sich nur an Abteilungsmitglieder richten.",
        GroupLive: [:index, :show]
      },
      sponsor: %{
        Name: "Sponsor",
        Info:
          "verfügt über die notwendigen Zugriffe Abteilungsinformationen und -angebote einzusehen, die sich an ausgewählte Dritte des Vereins richten."
      }
    ]
  end

  def basic_permissions_when_associated_to_club(currentpermissions, true, :ClubLive),
    do: currentpermissions ++ [:show]

  def basic_permissions_when_associated_to_club(currentpermissions, true, :DepartmentLive),
    do: currentpermissions ++ [:index]

  def basic_permissions_when_associated_to_club(currentpermissions, _false, _view),
    do: currentpermissions

  def basic_permissions_when_associated_to_department(currentpermissions, true, :DepartmentLive),
    do: currentpermissions ++ [:show]

  def basic_permissions_when_associated_to_department(currentpermissions, _false, _view),
    do: currentpermissions

  def get_role_names(atom) do
    atom
    |> role_permission_matrix()
    |> Keyword.values()
    |> Enum.map(&Map.get(&1, :Name))
  end

  def to_role_atom(atom, role) do
    atom
    |> role_permission_matrix()
    |> Enum.filter(fn {_key, value} -> Map.get(value, :Name) == role end)
    |> Keyword.keys()
    |> Enum.at(0)
  end
end
