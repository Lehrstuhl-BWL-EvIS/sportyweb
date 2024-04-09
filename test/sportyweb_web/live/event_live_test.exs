defmodule SportywebWeb.EventLiveTest do
  use SportywebWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.CalendarFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  @create_attrs %{
    description: "some description",
    location_type: "no_info",
    maximum_age_in_years: 42,
    maximum_participants: 42,
    minimum_age_in_years: 42,
    minimum_participants: 42,
    name: "some name",
    reference_number: "some reference_number",
    status: "draft"
  }
  @update_attrs %{
    description: "some updated description",
    location_type: "free_form",
    maximum_age_in_years: 43,
    maximum_participants: 43,
    minimum_age_in_years: 43,
    minimum_participants: 43,
    name: "some updated name",
    reference_number: "some updated reference_number",
    status: "public"
  }
  @invalid_attrs %{
    description: nil,
    location_type: "no_info",
    maximum_age_in_years: nil,
    maximum_participants: nil,
    minimum_age_in_years: nil,
    minimum_participants: nil,
    name: nil,
    reference_number: nil,
    status: "draft"
  }

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_event(_) do
    event = event_fixture()
    %{event: event}
  end

  describe "Index" do
    setup [:create_event]

    test "lists all events - default redirect", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/events")

      conn = conn |> log_in_user(user)

      {:ok, conn} =
        conn
        |> live(~p"/events")
        |> follow_redirect(conn, ~p"/clubs")

      assert conn.resp_body =~ "Vereinsübersicht"
    end

    test "lists all events", %{conn: conn, user: user, event: event} do
      {:error, _} = live(conn, ~p"/clubs/#{event.club_id}/events")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/clubs/#{event.club_id}/events")

      assert html =~ "Kalender"
      assert html =~ event.name
    end
  end

  describe "New/Edit" do
    setup [:create_event]

    test "saves new event", %{conn: conn, user: user} do
      club = club_fixture()

      {:error, _} = live(conn, ~p"/clubs/#{club}/events/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/clubs/#{club}/events/new")

      assert html =~ "Veranstaltung erstellen"

      assert new_live
             |> form("#event-form", event: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        new_live
        |> form("#event-form", event: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubs/#{club}/events")

      assert html =~ "Veranstaltung erfolgreich erstellt"
      assert html =~ "some name"
    end

    test "cancels save new event", %{conn: conn, user: user} do
      club = club_fixture()

      conn = conn |> log_in_user(user)
      {:ok, new_live, _html} = live(conn, ~p"/clubs/#{club}/events/new")

      {:ok, _, _html} =
        new_live
        |> element("#event-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{club}/events")
    end

    test "updates event", %{conn: conn, user: user, event: event} do
      {:error, _} = live(conn, ~p"/events/#{event}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/events/#{event}/edit")

      assert html =~ "Veranstaltung bearbeiten"

      assert edit_live
             |> form("#event-form", event: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#event-form", event: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/events/#{event}")

      assert html =~ "Veranstaltung erfolgreich aktualisiert"
      assert html =~ "some updated name"
    end

    test "cancels updates event", %{conn: conn, user: user, event: event} do
      conn = conn |> log_in_user(user)
      {:ok, edit_live, _html} = live(conn, ~p"/events/#{event}/edit")

      {:ok, _, _html} =
        edit_live
        |> element("#event-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/events/#{event}")
    end

    test "deletes event", %{conn: conn, user: user, event: event} do
      {:error, _} = live(conn, ~p"/events/#{event}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/events/#{event}/edit")
      assert html =~ "some name"

      {:ok, _, html} =
        edit_live
        |> element("#event-form button", "Löschen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{event.club_id}/events")

      assert html =~ "Veranstaltung erfolgreich gelöscht"
      assert html =~ "Kalender"
      refute html =~ "some name"
    end
  end

  describe "Show" do
    setup [:create_event]

    test "displays event", %{conn: conn, user: user, event: event} do
      {:error, _} = live(conn, ~p"/events/#{event}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/events/#{event}")

      assert html =~ "Veranstaltung:"
      assert html =~ event.name
    end
  end

  describe "FeeNew" do
    setup [:create_event]

    test "saves new event fee", %{conn: conn, user: user, event: event} do
      {:error, _} = live(conn, ~p"/events/#{event}/fees/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/events/#{event}/fees/new")

      assert html =~ "Spezifische Gebühr erstellen (Veranstaltung)"

      assert new_live
      |> form("#fee-form", fee: %{})
      |> render_change() =~ "can&#39;t be blank"

      create_attrs = %{
        amount: "30 €",
        amount_one_time: "10 €",
        name: "some name",
        internal_events: %{
          "0" => %{
            commission_date: ~D[2022-11-03]
          }
        }
      }

      {:ok, _, html} =
        new_live
        |> form("#fee-form", fee: create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/events/#{event}")

      assert html =~ "Gebühr erfolgreich erstellt"
      assert html =~ event.name
    end
  end
end
