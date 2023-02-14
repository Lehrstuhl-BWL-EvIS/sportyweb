defmodule SportywebWeb.VenueLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.AssetFixtures
  import Sportyweb.OrganizationFixtures

  @create_attrs %{description: "some description", is_main: true, name: "some name", reference_number: "some reference_number"}
  @update_attrs %{description: "some updated description", is_main: false, name: "some updated name", reference_number: "some updated reference_number"}
  @invalid_attrs %{description: nil, is_main: false, name: nil, reference_number: nil}

  setup do
    %{user: user_fixture()}
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
