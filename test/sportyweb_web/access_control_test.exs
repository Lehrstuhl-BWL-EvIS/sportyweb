defmodule SportywebWeb.AccessControlTest do
  use SportywebWeb.ConnCase, async: true

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Accounts
  alias Sportyweb.Organization.Club

  alias Sportyweb.AccessControl
  alias Sportyweb.AccessControl.PolicyClub

  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.AccessControlFixtures

  defp do_setup(_) do
    tester0 = Accounts.get_user_by_email("sportyweb_admin@tester.de")
    tester1 = Accounts.get_user_by_email("clubadmin@tester.de")
    tester2 = Accounts.get_user_by_email("clubsubadmin@tester.de")
    tester3 = Accounts.get_user_by_email("clubreadwritemember@tester.de")
    tester4 = Accounts.get_user_by_email("clubmember@tester.de")
    testers = [tester0, tester1, tester2, tester3, tester4]

    query_club = from club in Club,
      where: club.name == "1. FC Köln"

    club = Repo.all(query_club) |> Enum.at(0)

    %{club_admin: tester1, club_member: tester4, club: club}
  end

  describe "PolicyClub" do
    setup [:do_setup]

    test "user with higher role [club_admin] performs according to policy", %{club_admin: user, club: club} do
      assert user.email == "clubadmin@tester.de"
      assert club.name == "1. FC Köln"
      assert AccessControl.has_club_role(user, club.id) |> Enum.at(0) == "club_admin"

      assert PolicyClub.can?(user, :index, club.id) == true
      assert PolicyClub.can?(user, :new, club.id) == false
      assert PolicyClub.can?(user, :edit, club.id) == true
      assert PolicyClub.can?(user, "delete", club.id) == true
      assert PolicyClub.can?(user, :show, club.id) == true
      assert PolicyClub.can?(user, :userrolemanagement, club.id) == true
    end

    test "user with lower role [club_member] performs according to policy", %{club_member: user, club: club} do
      assert user.email == "clubmember@tester.de"
      assert club.name == "1. FC Köln"
      assert AccessControl.has_club_role(user, club.id) |> Enum.at(0) == "club_member"

      assert PolicyClub.can?(user, :index, club.id) == true
      assert PolicyClub.can?(user, :new, club.id) == false
      assert PolicyClub.can?(user, :edit, club.id) == false
      assert PolicyClub.can?(user, "delete", club.id) == false
      assert PolicyClub.can?(user, :show, club.id) == true
      assert PolicyClub.can?(user, :userrolemanagement, club.id) == false
    end
  end

end
