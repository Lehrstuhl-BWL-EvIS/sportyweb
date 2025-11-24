defmodule SportywebWeb.EntryLiveTest do
  use SportywebWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Sportyweb.AccountingFixtures
  import Sportyweb.AccountsFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_entry(_) do
    entry = entry_fixture()
    %{entry: entry}
  end

  describe "New/Edit" do
    setup [:create_entry]

    test "cancels save new entry", %{conn: conn, user: user} do
      transaction = transaction_fixture()

      conn = conn |> log_in_user(user)
      {:ok, new_live, _html} = live(conn, ~p"/transactions/#{transaction}/entries/new")

      {:ok, _, _html} =
        new_live
        |> element("#entry-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/transactions/#{transaction}")
    end

    test "cancels updates entry", %{conn: conn, user: user, entry: entry} do

      conn = conn |> log_in_user(user)
      {:ok, edit_live, _html} = live(conn, ~p"/transactions/#{entry.transaction_id}/entries/#{entry}/edit")

      {:ok, _, _html} =
        edit_live
        |> element("#entry-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/transactions/#{entry.transaction_id}/entries/#{entry}")
    end

    test "deletes entry", %{conn: conn, user: user, entry: entry} do
      transaction = transaction_fixture()

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/transactions/#{transaction}/entries/#{entry}/edit")

      assert html =~ "Buchung bearbeiten"

      {:ok, _, html} =
      edit_live
      |> element("#entry-form button", "Löschen")
      |> render_click()
      |> follow_redirect(conn, ~p"/transactions/#{entry.transaction_id}")

      assert html =~ "Buchung erfolgreich gelöscht"
      assert html =~ "Transaktion: some name"
      refute html =~ entry.id
    end
  end

  describe "Show" do
    setup [:create_entry]

    test "displays entry", %{conn: conn, user: user, entry: entry} do
      transaction = transaction_fixture()

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/transactions/#{transaction}/entries/#{entry}")

      assert html =~ "Buchung"
      refute html =~ entry.id
    end
  end
end
