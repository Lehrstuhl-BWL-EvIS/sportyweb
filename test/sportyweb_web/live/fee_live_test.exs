defmodule SportywebWeb.FeeLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.LegalFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  @create_attrs %{admission_fee_in_eur: 15, admission_fee_in_eur_cent: 1500, base_fee_in_eur: 42, base_fee_in_eur_cent: 4200, commission_date: "2023-02-24", archive_date: "2023-02-24", description: "some description", is_for_contact_group_contacts_only: true, is_recurring: true, maximum_age_in_years: 42, minimum_age_in_years: 42, name: "some name", reference_number: "some reference_number"}
  @update_attrs %{admission_fee_in_eur: 16, admission_fee_in_eur_cent: 1600, base_fee_in_eur: 43, base_fee_in_eur_cent: 4300, commission_date: "2023-02-25", archive_date: "2023-02-25", description: "some updated description", is_for_contact_group_contacts_only: false, is_recurring: false, maximum_age_in_years: 43, minimum_age_in_years: 43, name: "some updated name", reference_number: "some updated reference_number"}
  @invalid_attrs %{admission_fee_in_eur: nil, admission_fee_in_eur_cent: nil, base_fee_in_eur: nil, base_fee_in_eur_cent: nil, commission_date: nil, archive_date: nil, description: nil, is_for_contact_group_contacts_only: false, is_recurring: false, maximum_age_in_years: nil, minimum_age_in_years: nil, name: nil, reference_number: nil}

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
