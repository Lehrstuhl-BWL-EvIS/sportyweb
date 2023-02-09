defmodule SportywebWeb.ClubLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures

  @create_attrs %{founded_at: ~D[2022-11-05], name: "some name", reference_number: "some reference_number", website_url: "https://www.website_url.com"}
  @update_attrs %{founded_at: ~D[2022-11-06], name: "some updated name", reference_number: "some updated reference_number", website_url: "https://www.updated_website_url.com"}
  @invalid_attrs %{founded_at: nil, name: nil, reference_number: nil, website_url: nil}

  setup do
    %{user: user_fixture()}
  end

  defp create_club(_) do
    club = club_fixture()
    %{club: club}
  end

  describe "Index" do
    setup [:create_club]

    test "lists all clubs", %{conn: conn, user: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/clubs")

      assert html =~ "Vereinsübersicht"
      assert html =~ club.name
    end
  end

  describe "New/Edit" do
    setup [:create_club]

    test "saves new club", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/clubs/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/clubs/new")

      assert html =~ "Verein erstellen"

      assert new_live
             |> form("#club-form", club: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        new_live
        |> form("#club-form", club: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubs")

      assert html =~ "Verein erfolgreich erstellt"
      assert html =~ "some name"
    end

    test "updates club", %{conn: conn, user: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/clubs/#{club}/edit")

      assert html =~ "Verein bearbeiten"

      assert edit_live
             |> form("#club-form", club: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#club-form", club: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubs/#{club}")

      assert html =~ "Verein erfolgreich aktualisiert"
      assert html =~ "some updated name"
    end

    test "deletes club", %{conn: conn, user: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, _html} = live(conn, ~p"/clubs/#{club}/edit")

      # The original club should exist in the list
      {:ok, _index_live, html} = live(conn, ~p"/clubs")
      assert html =~ "some name"

      {:ok, _, html} =
        edit_live
        |> element("#club-form button", "Löschen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs")

      # The original club should no longer exist in the list
      assert html =~ "Verein erfolgreich gelöscht"
      refute html =~ "some name"
    end
  end

  describe "Show" do
    setup [:create_club]

    test "displays club", %{conn: conn, user: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/clubs/#{club}")

      assert html =~ "Dashboard"
      assert html =~ club.name
    end
  end
end
