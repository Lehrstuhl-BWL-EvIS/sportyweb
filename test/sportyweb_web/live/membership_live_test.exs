defmodule SportywebWeb.MembershipLiveTest do
  use SportywebWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.PersonalFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  @invalid_attrs %{
    contact_id: nil,
    department_id: nil,
    group_id: nil,
    start_date: nil,
    termination_date: nil,
    state: nil
  }

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_membership(_) do
    membership = membership_fixture()
    %{membership: membership}
  end

  describe "Index" do
    setup [:create_membership]

    test "lists all memberships - default redirect", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/memberships")

      conn = conn |> log_in_user(user)

      {:ok, conn} =
        conn
        |> live(~p"/memberships")
        |> follow_redirect(conn, ~p"/clubs")

      assert conn.resp_body =~ "Vereinsübersicht"
    end

    test "lists all memberships", %{conn: conn, user: user, membership: membership} do
      {:error, _} = live(conn, ~p"/clubs/#{membership.club_id}/memberships")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/clubs/#{membership.club_id}/memberships")

      assert html =~ "Mitgliedschaften"
      assert html =~ "<table"
      assert html =~ "Es werden 1 von 1 passenden Mitgliedschaften angezeigt"
    end
  end

  describe "New/Edit" do
    setup [:create_membership]

    test "saves new membership", %{conn: conn, user: user} do
      club = club_fixture()
      contact = contact_fixture(%{club_id: club.id})
      department = department_fixture(%{club_id: club.id})

      {:error, _} = live(conn, ~p"/clubs/#{club}/memberships/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/clubs/#{club}/memberships/new")

      assert html =~ "Neue Mitgliedschaft anlegen"

      assert new_live
             |> form("#membership-form", membership: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      create_attrs = %{
        contact_id: contact.id,
        department_id: department.id,
        start_date: ~D[2022-11-05],
        state: "active"
      }

      {:ok, _, html} =
        new_live
        |> form("#membership-form", membership: create_attrs)
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Mitgliedschaft erfolgreich erstellt"
      assert html =~ "some name"
    end

    test "cancels save new membership", %{conn: conn, user: user} do
      club = club_fixture()

      conn = conn |> log_in_user(user)
      {:ok, new_live, _html} = live(conn, ~p"/clubs/#{club}/memberships/new")

      {:ok, _, _html} =
        new_live
        |> element("#membership-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{club}/memberships")
    end

    test "updates membership", %{conn: conn, user: user, membership: membership} do
      {:error, _} = live(conn, ~p"/memberships/#{membership}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/memberships/#{membership}/edit")

      assert html =~ "Mitgliedschaft von"
      assert html =~ "bearbeiten"

      assert edit_live
             |> form("#membership-form", membership: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      update_attrs = %{
        contact_id: membership.contact_id,
        start_date: ~D[2020-11-06],
        termination_date: ~D[2026-11-06],
        state: "terminated"
      }

      {:ok, _, html} =
        edit_live
        |> form("#membership-form", membership: update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/memberships/#{membership}")

      assert html =~ "Mitgliedschaft erfolgreich aktualisiert"
      assert html =~ "06.11.2020"
      assert html =~ "06.11.2026"
      assert html =~ "Beendet"
    end

    test "cancels updates membership", %{conn: conn, user: user, membership: membership} do
      conn = conn |> log_in_user(user)
      {:ok, edit_live, _html} = live(conn, ~p"/memberships/#{membership}/edit")

      {:ok, _, _html} =
        edit_live
        |> element("#membership-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/memberships/#{membership}")
    end

    test "deletes membership", %{conn: conn, user: user, membership: membership} do
      {:error, _} = live(conn, ~p"/memberships/#{membership}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/memberships/#{membership}/edit")
      assert html =~ "some name"

      {:ok, _, html} =
        edit_live
        |> element("#membership-form button", "Löschen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{membership.club_id}/memberships")

      assert html =~ "Mitgliedschaft erfolgreich gelöscht"
      assert html =~ "Abteilungen"
      refute html =~ "some name"
    end
  end

  describe "Show" do
    setup [:create_membership]

    test "displays membership", %{conn: conn, user: user, membership: membership} do
      {:error, _} = live(conn, ~p"/memberships/#{membership}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/memberships/#{membership}")

      assert html =~ "Mitgliedschaft von"
      assert html =~ SportywebWeb.CommonHelper.format_date_field_dmy(membership.start_date)
      assert html =~ "Beitrag"
    end
  end
end
