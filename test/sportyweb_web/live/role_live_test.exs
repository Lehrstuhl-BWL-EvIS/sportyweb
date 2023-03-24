defmodule SportywebWeb.RoleLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    club_admin = user_fixture()

    club = club_fixture()
    clubrole_admin = club_role_fixture(%{name: "Vereins Administration"})
    ucr_admin = user_club_role_fixture(%{user_id: club_admin.id, club_id: club.id, clubrole_id: clubrole_admin.id})

    clubrole_other = club_role_fixture(%{name: "Vorstand"})

    department = department_fixture(%{club_id: club.id})
    department_role = department_role_fixture(%{name: "Abteilungleiter"})
    user_department_role_fixture(%{user_id: club_admin.id, department_id: department.id, departmentrole_id: department_role.id})

    department_role_other = department_role_fixture(%{name: "Abteilungsmitglied"})

    %{
      user: user,
      club_admin: club_admin,
      club: club,
      clubrole_admin: clubrole_admin,
      clubrole_other: clubrole_other,
      ucr_admin: ucr_admin,
      department: department,
      department_role_other: department_role_other
    }
  end

  describe "Index" do
    test "lists all userclubroles in club", %{conn: conn, user: user, club: club, club_admin: club_admin, clubrole_admin: clubrole_admin} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/roles")

      conn = conn |> log_in_user(user)
      {:ok, index_live, html} = live(conn, ~p"/clubs/#{club.id}/roles")

      assert html =~ "Rollen"
      assert html =~ club_admin.email
      assert html =~ clubrole_admin.name

      {:ok, _, newhtml} = index_live
             |> element("#roles a", "Bearbeiten")
             |> render_click()
             |> follow_redirect(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      assert newhtml =~ "Rollen von #{club_admin.email}"
    end
  end

  describe "Edit" do
    test "add clubrole to user in club", %{conn: conn, user: user, club_admin: club_admin, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      assert html =~ "Rollen von #{club_admin.email}"
      assert html =~ "im Verein #{club.name}"
      assert html =~ "Zugewiesene Rollen"
      assert html =~ "Entfernen"
      assert html =~ "Vereinsrollen"
      assert html =~ "Rollen in der Abteilung"
      assert html =~ "Hinzufügen"

      {:ok, _, addhtml} =
        edit_live
        |> element("#available_club_roles button", "Hinzufügen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

        assert addhtml =~ "Rollen von #{club_admin.email}"
        assert addhtml =~ "Die Rolle wurde dem Nutzer erfolgreich hinzugefügt."
    end

    test "add departmentrole to user in club", %{conn: conn, user: user, club_admin: club_admin, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      assert html =~ "Rollen von #{club_admin.email}"
      assert html =~ "im Verein #{club.name}"
      assert html =~ "Zugewiesene Rollen"

      {:ok, _, addhtml} =
        edit_live
        |> element("#adr button", "Hinzufügen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

        assert addhtml =~ "Rollen von #{club_admin.email}"
        assert addhtml =~ "Die Rolle wurde dem Nutzer erfolgreich hinzugefügt."
    end

    test "remove clubrole from user in club", %{conn: conn, user: user, club_admin: club_admin, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      assert html =~ "Rollen von #{club_admin.email}"
      assert html =~ "im Verein #{club.name}"
      assert html =~ "Zugewiesene Rollen"
      assert html =~ "Entfernen"
      assert html =~ "Vereinsrollen"
      assert html =~ "Rollen in der Abteilung"
      assert html =~ "Hinzufügen"

      {:ok, _, removehtml} =
      edit_live
      |> element("#assigned_club_roles button", "Entfernen")
      |> render_click()
      |> follow_redirect(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      assert removehtml =~ "Rollen von #{club_admin.email}"
      assert removehtml =~ "Die Rolle wurde erfolgreich vom Nutzer entfernt."
    end

    test "remove departmentrole from user in club", %{conn: conn, user: user, club_admin: club_admin, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      assert html =~ "Rollen von #{club_admin.email}"
      assert html =~ "im Verein #{club.name}"
      assert html =~ "im Verein"
      assert html =~ "in den Abteilungen"

      {:ok, _, addhtml} =
        edit_live
        |> element("#assigned_department_roles button", "Entfernen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

        assert addhtml =~ "Rollen von #{club_admin.email}"
        assert addhtml =~ "Die Rolle wurde erfolgreich vom Nutzer entfernt."
    end
  end

  describe "New" do
    test "add userclubrole to club", %{conn: conn, user: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/roles/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/clubs/#{club.id}/roles/new")

      assert html =~ "Mitarbeiter zu #{club.name} hinzufügen"
      assert html =~ "Verwalter: #{user.email}"

      email = unique_user_email()
      {:ok, _, newhtml} = new_live
      |> form("#add_user_form", user: %{email: email})
      |> render_submit()
      |> follow_redirect(conn,  ~p"/clubs/#{club.id}/roles/#{Sportyweb.Accounts.get_user_by_email(email).id}/edit")

      added_user = Sportyweb.Accounts.get_user_by_email(email)
      assert email == added_user.email

      assert newhtml =~ "Vergib dem Nutzer eine Rolle um ihn dem Verein hinzuzufügen."
      assert newhtml =~ "Rollen von #{added_user.email}"
      assert newhtml =~ "im Verein #{club.name}"
      assert newhtml =~ "Zugewiesene Rollen"
      refute newhtml =~ "Entfernen"
      assert newhtml =~ "Vereinsrollen"
      assert newhtml =~ "Rollen in der Abteilung"
      assert newhtml =~ "Hinzufügen"
    end
  end
end
