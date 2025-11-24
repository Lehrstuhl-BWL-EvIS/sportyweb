defmodule SportywebWeb.AccountLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.AccountingFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures
  import Sportyweb.OrganizationFixtures

  @create_attrs %{name: "some name", class: "Umlaufvermögen", account_number: 16000}
  @update_attrs %{name: "some updated name", class: "Einnahmen", account_number: 41234, archive_date: ~D[2025-11-20]}
  @invalid_attrs %{name: nil, class: "", account_number: nil}

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_account(_) do
    account = account_fixture()
    %{account: account}
  end

  describe "Index" do
    setup [:create_account]

    test "lists all accounts - default redirect", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/accounts")

       conn = conn |> log_in_user(user)

       {:ok, conn} =
       conn
       |> live(~p"/accounts")
       |> follow_redirect(conn, ~p"/clubs")

    assert conn.resp_body =~ "Vereinsübersicht"
    end

    test "lists all accounts", %{conn: conn, user: user, account: account} do
      {:error, _} = live(conn, ~p"/clubs/#{account.club_id}/accounts")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/clubs/#{account.club_id}/accounts")

      assert html =~ "Kontenplan"
      assert html =~ account.name
    end
  end

    describe "New/Edit" do
    setup [:create_account]

    test "saves new account", %{conn: conn, user: user} do
      club = club_fixture()

      {:error, _} = live(conn, ~p"/clubs/#{club}/accounts/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/clubs/#{club}/accounts/new")

      assert html =~ "Konto erstellen"

      assert new_live
              |> form("#account-form", account: @invalid_attrs)
              |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        new_live
        |> form("#account-form", account: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubs/#{club}/accounts")

      assert html =~ "Konto erfolgreich erstellt"
      assert html =~ "some name"
    end

    test "cancels save new account", %{conn: conn, user: user} do
      club = club_fixture()

      conn = conn |> log_in_user(user)
      {:ok, new_live, _html} = live(conn, ~p"/clubs/#{club}/accounts/new")

      {:ok, _, _html} =
        new_live
        |> element("#account-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{club}/accounts")
    end

    test "updates account", %{conn: conn, user: user, account: account} do

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/accounts/#{account}/edit")

      assert html =~ "Konto bearbeiten"

      assert edit_live
        |> form("#account-form", account: @invalid_attrs)
        |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#account-form", account: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/accounts/#{account}")

      assert html =~ "Konto erfolgreich aktualisiert"
      assert html =~ "Konto: some updated name"
    end

    test "cancels updates account", %{conn: conn, user: user, account: account} do
      conn = conn |> log_in_user(user)
      {:ok, edit_live, _html} = live(conn, ~p"/accounts/#{account}/edit")

      {:ok, _, _html} =
        edit_live
        |> element("#account-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/accounts/#{account}")
    end

    test "deletes account", %{conn: conn, user: user, account: account} do
      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/accounts/#{account}/edit")
      assert html =~ "some name"

      {:ok, _, html} =
      edit_live
      |> element("#account-form button", "Löschen")
      |> render_click()
      |> follow_redirect(conn, ~p"/clubs/#{account.club_id}/accounts")

      assert html =~ "Konto erfolgreich gelöscht"
      assert html =~ "Kontenplan"
      refute html =~ "some name"
    end
  end


  describe "Show" do
    setup [:create_account]

    test "displays account", %{conn: conn, user: user, account: account} do

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/accounts/#{account}")

      assert html =~ "Konto:"
      assert html =~ account.name
    end

  end
end
