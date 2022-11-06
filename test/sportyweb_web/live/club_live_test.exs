defmodule SportywebWeb.ClubLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.OrganizationFixtures

  @create_attrs %{founded_at: "2022-11-5", name: "some name", reference_number: "some reference_number", website_url: "some website_url"}
  @update_attrs %{founded_at: "2022-11-6", name: "some updated name", reference_number: "some updated reference_number", website_url: "some updated website_url"}
  @invalid_attrs %{founded_at: nil, name: nil, reference_number: nil, website_url: nil}

  defp create_club(_) do
    club = club_fixture()
    %{club: club}
  end

  describe "Index" do
    setup [:create_club]

    test "lists all clubs", %{conn: conn, club: club} do
      {:ok, _index_live, html} = live(conn, ~p"/clubs")

      assert html =~ "Listing Clubs"
      assert html =~ club.name
    end

    test "saves new club", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/clubs")

      assert index_live |> element("a", "New Club") |> render_click() =~
               "New Club"

      assert_patch(index_live, ~p"/clubs/new")

      assert index_live
             |> form("#club-form", club: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#club-form", club: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubs")

      assert html =~ "Club created successfully"
      assert html =~ "some name"
    end

    test "updates club in listing", %{conn: conn, club: club} do
      {:ok, index_live, _html} = live(conn, ~p"/clubs")

      assert index_live |> element("#clubs-#{club.id} a", "Edit") |> render_click() =~
               "Edit Club"

      assert_patch(index_live, ~p"/clubs/#{club}/edit")

      assert index_live
             |> form("#club-form", club: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#club-form", club: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubs")

      assert html =~ "Club updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes club in listing", %{conn: conn, club: club} do
      {:ok, index_live, _html} = live(conn, ~p"/clubs")

      assert index_live |> element("#clubs-#{club.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#club-#{club.id}")
    end
  end

  describe "Show" do
    setup [:create_club]

    test "displays club", %{conn: conn, club: club} do
      {:ok, _show_live, html} = live(conn, ~p"/clubs/#{club}")

      assert html =~ "Show Club"
      assert html =~ club.name
    end

    test "updates club within modal", %{conn: conn, club: club} do
      {:ok, show_live, _html} = live(conn, ~p"/clubs/#{club}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Club"

      assert_patch(show_live, ~p"/clubs/#{club}/show/edit")

      assert show_live
             |> form("#club-form", club: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#club-form", club: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubs/#{club}")

      assert html =~ "Club updated successfully"
      assert html =~ "some updated name"
    end
  end
end
