defmodule Sportyweb.RBACTest do
  use Sportyweb.DataCase

  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  alias Sportyweb.RBAC

  setup do
    user = user_fixture()
    club = club_fixture()
    clubrole = club_role_fixture()
    clubrole2 = club_role_fixture(%{name: "other role"})
    user_club_role_fixture(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole.id})
    user_club_role_fixture(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole2.id})

    roles = [clubrole, clubrole2] |> Enum.map_join(", ", &(&1.name))

    %{club: club, role_attr: %{id: user.id, name: user.email, roles: roles}}
  end

  describe "roles" do
    import Sportyweb.RBACFixtures

    test "list_roles/1 returns list of role structs of a club", %{club: club, role_attr: role_attr} do
      role = role_fixture(role_attr)
      assert RBAC.list_roles(club.id) == [role]
    end
  end
end
