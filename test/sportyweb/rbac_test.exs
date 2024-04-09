defmodule Sportyweb.RBACTest do
  use Sportyweb.DataCase, async: true

  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  alias Sportyweb.RBAC

  setup do
    user = user_fixture()
    club = club_fixture()
    department = department_fixture(%{club_id: club.id})

    clubrole = club_role_fixture(%{name: "Vereinsadministration"})
    clubrole2 = club_role_fixture(%{name: "Geschäftsführung"})
    user_club_role_fixture(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole.id})
    user_club_role_fixture(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole2.id})

    departmentrole = department_role_fixture(%{name: "Abteilungsleiter"})
    departmentrole2 = department_role_fixture(%{name: "Abteilungsmitglied"})

    user_department_role_fixture(%{
      user_id: user.id,
      department_id: department.id,
      departmentrole_id: departmentrole.id
    })

    user_department_role_fixture(%{
      user_id: user.id,
      department_id: department.id,
      departmentrole_id: departmentrole2.id
    })

    clubroles = [clubrole, clubrole2] |> Enum.map_join(", ", & &1.name)

    departmentroles =
      [departmentrole, departmentrole2] |> Enum.map_join(", ", &"#{&1.name} #{club.name}")

    %{
      club: club,
      role_attr: %{
        id: user.id,
        name: user.email,
        clubroles: clubroles,
        departmentroles: departmentroles
      }
    }
  end

  describe "roles" do
    import Sportyweb.RBACFixtures

    test "list_roles/1 returns list of role structs of a club", %{
      club: club,
      role_attr: role_attr
    } do
      role = role_fixture(role_attr)
      assert RBAC.list_roles(club.id) == [role]
    end
  end
end
