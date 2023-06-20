defmodule SportywebWeb.FeeLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.FinanceFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  @create_attrs %{
    amount_one_time: "10 €",
    amount: "30 €",
    description: "some description",
    is_for_contact_group_contacts_only: true,
    is_general: true,
    maximum_age_in_years: 30,
    minimum_age_in_years: 10,
    name: "some name",
    reference_number: "some reference_number",
    type: "club",
    internal_events: %{
      "0" => %{
        commission_date: ~D[2023-01-01],
      }
    }
  }
  @update_attrs %{
    amount_one_time: "15 €",
    amount: "40 €",
    description: "some updated description",
    is_for_contact_group_contacts_only: false,
    maximum_age_in_years: 40,
    minimum_age_in_years: 20,
    name: "some updated name",
    reference_number: "some updated reference_number",
    type: "club"
  }
  @invalid_attrs %{
    amount_one_time: nil,
    amount: nil,
    description: nil,
    is_for_contact_group_contacts_only: false,
    maximum_age_in_years: nil,
    minimum_age_in_years: nil,
    name: nil,
    reference_number: nil,
    type: nil
  }

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_fee(_) do
    fee = fee_fixture()
    %{fee: fee}
  end

  describe "Index" do
    setup [:create_fee]

    test "lists all fees - default redirect", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/fees")

      conn = conn |> log_in_user(user)

      {:ok, conn} =
        conn
        |> live(~p"/fees")
        |> follow_redirect(conn, ~p"/clubs")

      assert conn.resp_body =~ "Vereinsübersicht"
    end

    test "lists all fees", %{conn: conn, user: user, fee: fee} do
      {:error, _} = live(conn, ~p"/clubs/#{fee.club_id}/fees")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/clubs/#{fee.club_id}/fees")

      assert html =~ "Gebühren"
      assert html =~ fee.name
    end
  end

  describe "New/Edit" do
    setup [:create_fee]

    test "saves new fee", %{conn: conn, user: user} do
      club = club_fixture()

      {:error, _} = live(conn, ~p"/clubs/#{club}/fees/new/club")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/clubs/#{club}/fees/new/club")

      assert html =~ "Gebühr erstellen"

      assert new_live
             |> form("#fee-form", fee: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        new_live
        |> form("#fee-form", fee: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubs/#{club}/fees")

      assert html =~ "Gebühr erfolgreich erstellt"
      assert html =~ "some name"
    end

    test "cancels save new fee", %{conn: conn, user: user} do
      club = club_fixture()

      conn = conn |> log_in_user(user)
      {:ok, new_live, _html} = live(conn, ~p"/clubs/#{club}/fees/new/club")

      {:ok, _, _html} =
        new_live
        |> element("#fee-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{club}/fees")
    end

    test "updates fee", %{conn: conn, user: user, fee: fee} do
      {:error, _} = live(conn, ~p"/fees/#{fee}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/fees/#{fee}/edit")

      assert html =~ "Gebühr bearbeiten"

      assert edit_live
             |> form("#fee-form", fee: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#fee-form", fee: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/fees/#{fee}")

      assert html =~ "Gebühr erfolgreich aktualisiert"
      assert html =~ "some updated name"
    end

    test "cancels updates fee", %{conn: conn, user: user, fee: fee} do
      conn = conn |> log_in_user(user)
      {:ok, edit_live, _html} = live(conn, ~p"/fees/#{fee}/edit")

      {:ok, _, _html} =
        edit_live
        |> element("#fee-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/fees/#{fee}")
    end

    test "deletes fee", %{conn: conn, user: user, fee: fee} do
      {:error, _} = live(conn, ~p"/fees/#{fee}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/fees/#{fee}/edit")
      assert html =~ "some name"

      {:ok, _, html} =
        edit_live
        |> element("#fee-form button", "Löschen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{fee.club_id}/fees")

      assert html =~ "Gebühr erfolgreich gelöscht"
      assert html =~ "Gebühren"
      refute html =~ "some name"
    end
  end

  describe "Show" do
    setup [:create_fee]

    test "displays fee", %{conn: conn, user: user, fee: fee} do
      {:error, _} = live(conn, ~p"/fees/#{fee}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/fees/#{fee}")

      assert html =~ "Gebühr:"
      assert html =~ fee.name
    end
  end
end
