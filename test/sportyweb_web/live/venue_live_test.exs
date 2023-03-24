defmodule SportywebWeb.VenueLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.AssetFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  @create_attrs %{description: "some description", name: "some name", reference_number: "some reference_number"}
  @update_attrs %{description: "some updated description", name: "some updated name", reference_number: "some updated reference_number"}
  @invalid_attrs %{description: nil, name: nil, reference_number: nil}

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_venue(_) do
    venue = venue_fixture()
    %{venue: venue}
  end

  describe "Index" do
    setup [:create_venue]

    test "lists all venues - default redirect", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/venues")

      conn = conn |> log_in_user(user)
      {:ok, conn} =
        conn
        |> live(~p"/venues")
        |> follow_redirect(conn, ~p"/clubs")

      assert conn.resp_body =~ "Vereinsübersicht"
    end

    test "lists all venues", %{conn: conn, user: user, venue: venue} do
      {:error, _} = live(conn, ~p"/clubs/#{venue.club_id}/venues")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/clubs/#{venue.club_id}/venues")

      assert html =~ "Standorte"
      assert html =~ venue.name
    end
  end

  describe "New/Edit" do
    setup [:create_venue]

    test "saves new venue", %{conn: conn, user: user} do
      club = club_fixture()

      {:error, _} = live(conn, ~p"/clubs/#{club}/venues/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/clubs/#{club}/venues/new")

      assert html =~ "Standort erstellen"

      assert new_live
              |> form("#venue-form", venue: @invalid_attrs)
              |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        new_live
        |> form("#venue-form", venue: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubs/#{club}/venues")

      assert html =~ "Standort erfolgreich erstellt"
      assert html =~ "some name"
    end

    test "cancels save new venue", %{conn: conn, user: user} do
      club = club_fixture()

      conn = conn |> log_in_user(user)
      {:ok, new_live, _html} = live(conn, ~p"/clubs/#{club}/venues/new")

      {:ok, _, _html} =
        new_live
        |> element("#venue-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{club}/venues")
    end

    test "updates venue", %{conn: conn, user: user, venue: venue} do
      {:error, _} = live(conn, ~p"/venues/#{venue}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/venues/#{venue}/edit")

      assert html =~ "Standort bearbeiten"

      assert edit_live
             |> form("#venue-form", venue: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#venue-form", venue: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/venues/#{venue}")

      assert html =~ "Standort erfolgreich aktualisiert"
      assert html =~ "some updated name"
    end

    test "cancels updates venue", %{conn: conn, user: user, venue: venue} do
      conn = conn |> log_in_user(user)
      {:ok, edit_live, _html} = live(conn, ~p"/venues/#{venue}/edit")

      {:ok, _, _html} =
        edit_live
        |> element("#venue-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/venues/#{venue}")
    end

    test "deletes venue", %{conn: conn, user: user, venue: venue} do
      {:error, _} = live(conn, ~p"/venues/#{venue}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/venues/#{venue}/edit")
      assert html =~ "some name"

      {:ok, _, html} =
        edit_live
        |> element("#venue-form button", "Löschen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{venue.club_id}/venues")

      assert html =~ "Standort erfolgreich gelöscht"
      assert html =~ "Standorte"
      refute html =~ "some name"
    end
  end

  describe "Show" do
    setup [:create_venue]

    test "displays venue", %{conn: conn, user: user, venue: venue} do
      {:error, _} = live(conn, ~p"/venues/#{venue}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/venues/#{venue}")

      assert html =~ "Standort:"
      assert html =~ venue.name
    end
  end
end
