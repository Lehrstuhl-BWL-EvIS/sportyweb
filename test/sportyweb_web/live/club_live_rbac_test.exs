# credo:disable-for-this-file Credo.Check.Design.DuplicatedCode
defmodule SportywebWeb.Live.ClubLiveRbacTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  setup do
    #Users
    user_app_admin = user_fixture()
    user_club_admin = user_fixture()
    user_club_role = user_fixture()
    user_club_department_admin = user_fixture()
    user_other = user_fixture()

    #ApplicationRoles
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user_app_admin.id, applicationrole_id: applicationrole.id})

    #Clubs
    department = department_fixture()
    club = department.club_id |> Sportyweb.Organization.get_club!()

    #ClubRoles
    clubrole_admin = club_role_fixture(%{name: "Vereinsadministration"})
    user_club_role_fixture(%{user_id: user_club_admin.id, club_id: club.id, clubrole_id: clubrole_admin.id})

    clubrole_role = club_role_fixture(%{name: "Rollenverwaltung"})
    user_club_role_fixture(%{user_id: user_club_role.id, club_id: club.id, clubrole_id: clubrole_role.id})

    deparmentrole_dept_lead = department_role_fixture(%{name: "Abteilungsleiter"})
    user_department_role_fixture(%{user_id: user_club_department_admin.id, department_id: department.id, departmentrole_id: deparmentrole_dept_lead.id})

    %{
      user_app_admin: user_app_admin,
      user_club_admin: user_club_admin,
      user_club_role: user_club_role,
      user_club_department_admin: user_club_department_admin,
      user_other: user_other,
      club: club,
    }
  end

  describe "New" do
    test "save new club as app_admin", %{conn: conn, user_app_admin: user} do
      {:error, _} = live(conn, ~p"/clubs/new")

      conn = conn |> log_in_user(user)
      {:ok, _new_live, _html} = live(conn, ~p"/clubs/new")
    end

    test "save new club as club_admin", %{conn: conn, user_club_admin: user} do
      {:error, _} = live(conn, ~p"/clubs/new")

      conn = conn |> log_in_user(user)
      {:error, {:live_redirect , %{flash: %{"error" => msg}, to: _}}} = live(conn, ~p"/clubs/new")

      assert msg =~ "Zugriff verweigert."
    end

    test "save new club as role_admin", %{conn: conn, user_club_role: user} do
      {:error, _} = live(conn, ~p"/clubs/new")

      conn = conn |> log_in_user(user)
      {:error, {:live_redirect , %{flash: %{"error" => msg}, to: _}}} = live(conn, ~p"/clubs/new")

      assert msg =~ "Zugriff verweigert."
    end

    test "save new club as department_lead", %{conn: conn, user_club_department_admin: user} do
      {:error, _} = live(conn, ~p"/clubs/new")

      conn = conn |> log_in_user(user)
      {:error, {:live_redirect , %{flash: %{"error" => msg}, to: _}}} = live(conn, ~p"/clubs/new")

      assert msg =~ "Zugriff verweigert."
    end

    test "save new club as other", %{conn: conn, user_other: user} do
      {:error, _} = live(conn, ~p"/clubs/new")

      conn = conn |> log_in_user(user)
      {:error, {:live_redirect , %{flash: %{"error" => msg}, to: _}}} = live(conn, ~p"/clubs/new")

      assert msg =~ "Zugriff verweigert."
    end
  end

  describe "Edit" do
    test "edit club as app_admin", %{conn: conn, user_app_admin: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/edit")

      conn = conn |> log_in_user(user)
      {:ok, _live, _html} = live(conn, ~p"/clubs/#{club.id}/edit")
    end

    test "edit club as club_admin", %{conn: conn, user_club_admin: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/edit")

      conn = conn |> log_in_user(user)
      {:ok, _live, _html} = live(conn, ~p"/clubs/#{club.id}/edit")
    end

    test "edit club as role_admin", %{conn: conn, user_club_role: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/edit")

      conn = conn |> log_in_user(user)
      {:error, {:live_redirect , %{flash: %{"error" => msg}, to: _}}} = live(conn, ~p"/clubs/#{club.id}/edit")

      assert msg =~ "Zugriff verweigert."
    end

    test "edit club as department_lead", %{conn: conn, user_club_department_admin: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/edit")

      conn = conn |> log_in_user(user)
      {:error, {:live_redirect , %{flash: %{"error" => msg}, to: _}}} = live(conn, ~p"/clubs/#{club.id}/edit")

      assert msg =~ "Zugriff verweigert."
    end

    test "edit club as other", %{conn: conn, user_other: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/edit")

      conn = conn |> log_in_user(user)
      {:error, {:live_redirect , %{flash: %{"error" => msg}, to: _}}} = live(conn, ~p"/clubs/#{club.id}/edit")

      assert msg =~ "Zugriff verweigert."
    end
  end

  describe "Show" do
    test "show club as app_admin", %{conn: conn, user_app_admin: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}")

      conn = conn |> log_in_user(user)
      {:ok, _live, _html} = live(conn, ~p"/clubs/#{club.id}")
    end

    test "show club as club_admin", %{conn: conn, user_club_admin: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}")

      conn = conn |> log_in_user(user)
      {:ok, _live, _html} = live(conn, ~p"/clubs/#{club.id}")
    end

    test "show club as role_admin", %{conn: conn, user_club_role: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}")

      conn = conn |> log_in_user(user)
      {:ok, _live, _html} = live(conn, ~p"/clubs/#{club.id}")
    end

    test "show club as department_lead", %{conn: conn, user_club_department_admin: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}")

      conn = conn |> log_in_user(user)
      {:ok, _live, _html} = live(conn, ~p"/clubs/#{club.id}")
    end

    test "show club as other", %{conn: conn, user_other: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}")

      conn = conn |> log_in_user(user)
      {:error, {:live_redirect , %{flash: %{"error" => msg}, to: _}}} = live(conn, ~p"/clubs/#{club.id}")

      assert msg =~ "Zugriff verweigert."
    end
  end
end
