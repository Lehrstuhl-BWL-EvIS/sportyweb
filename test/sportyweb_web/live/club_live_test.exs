defmodule SportywebWeb.ClubLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.OrganizationsFixtures

  @create_attrs %{founding_date: %{day: 29, month: 10, year: 2022}, name: "some name", reference_number: "some reference_number", website_url: "some website_url"}
  @update_attrs %{founding_date: %{day: 30, month: 10, year: 2022}, name: "some updated name", reference_number: "some updated reference_number", website_url: "some updated website_url"}
  @invalid_attrs %{founding_date: %{day: 30, month: 2, year: 2022}, name: nil, reference_number: nil, website_url: nil}

  defp create_club(_) do
    club = club_fixture()
    %{club: club}
  end

  describe "Index" do
    setup [:create_club]

    test "lists all clubs", %{conn: conn, club: club} do
      {:ok, _index_live, html} = live(conn, Routes.club_index_path(conn, :index))

      assert html =~ "Listing Clubs"
      assert html =~ club.name
    end

    test "saves new club", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.club_index_path(conn, :index))

      assert index_live |> element("a", "New Club") |> render_click() =~
               "New Club"

      assert_patch(index_live, Routes.club_index_path(conn, :new))

      assert index_live
             |> form("#club-form", club: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#club-form", club: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.club_index_path(conn, :index))

      assert html =~ "Club created successfully"
      assert html =~ "some name"
    end

    test "updates club in listing", %{conn: conn, club: club} do
      {:ok, index_live, _html} = live(conn, Routes.club_index_path(conn, :index))

      assert index_live |> element("#club-#{club.id} a", "Edit") |> render_click() =~
               "Edit Club"

      assert_patch(index_live, Routes.club_index_path(conn, :edit, club))

      assert index_live
             |> form("#club-form", club: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#club-form", club: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.club_index_path(conn, :index))

      assert html =~ "Club updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes club in listing", %{conn: conn, club: club} do
      {:ok, index_live, _html} = live(conn, Routes.club_index_path(conn, :index))

      assert index_live |> element("#club-#{club.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#club-#{club.id}")
    end
  end

  describe "Show" do
    setup [:create_club]

    test "displays club", %{conn: conn, club: club} do
      {:ok, _show_live, html} = live(conn, Routes.club_show_path(conn, :show, club))

      assert html =~ "Show Club"
      assert html =~ club.name
    end

    test "updates club within modal", %{conn: conn, club: club} do
      {:ok, show_live, _html} = live(conn, Routes.club_show_path(conn, :show, club))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Club"

      assert_patch(show_live, Routes.club_show_path(conn, :edit, club))

      assert show_live
             |> form("#club-form", club: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#club-form", club: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.club_show_path(conn, :show, club))

      assert html =~ "Club updated successfully"
      assert html =~ "some updated name"
    end
  end
end
