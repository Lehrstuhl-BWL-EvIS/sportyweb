defmodule SportywebWeb.VenueLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AssetFixtures

  @create_attrs %{description: "some description", is_main: true, name: "some name", reference_number: "some reference_number"}
  @update_attrs %{description: "some updated description", is_main: false, name: "some updated name", reference_number: "some updated reference_number"}
  @invalid_attrs %{description: nil, is_main: false, name: nil, reference_number: nil}

  defp create_venue(_) do
    venue = venue_fixture()
    %{venue: venue}
  end

  describe "Index" do
    setup [:create_venue]

    test "lists all venues", %{conn: conn, venue: venue} do
      {:ok, _index_live, html} = live(conn, ~p"/venues")

      assert html =~ "Listing Venues"
      assert html =~ venue.description
    end

    test "saves new venue", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/venues")

      assert index_live |> element("a", "New Venue") |> render_click() =~
               "New Venue"

      assert_patch(index_live, ~p"/venues/new")

      assert index_live
             |> form("#venue-form", venue: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#venue-form", venue: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/venues")

      assert html =~ "Venue created successfully"
      assert html =~ "some description"
    end

    test "updates venue in listing", %{conn: conn, venue: venue} do
      {:ok, index_live, _html} = live(conn, ~p"/venues")

      assert index_live |> element("#venues-#{venue.id} a", "Edit") |> render_click() =~
               "Edit Venue"

      assert_patch(index_live, ~p"/venues/#{venue}/edit")

      assert index_live
             |> form("#venue-form", venue: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#venue-form", venue: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/venues")

      assert html =~ "Venue updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes venue in listing", %{conn: conn, venue: venue} do
      {:ok, index_live, _html} = live(conn, ~p"/venues")

      assert index_live |> element("#venues-#{venue.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#venue-#{venue.id}")
    end
  end

  describe "Show" do
    setup [:create_venue]

    test "displays venue", %{conn: conn, venue: venue} do
      {:ok, _show_live, html} = live(conn, ~p"/venues/#{venue}")

      assert html =~ "Show Venue"
      assert html =~ venue.description
    end

    test "updates venue within modal", %{conn: conn, venue: venue} do
      {:ok, show_live, _html} = live(conn, ~p"/venues/#{venue}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Venue"

      assert_patch(show_live, ~p"/venues/#{venue}/show/edit")

      assert show_live
             |> form("#venue-form", venue: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#venue-form", venue: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/venues/#{venue}")

      assert html =~ "Venue updated successfully"
      assert html =~ "some updated description"
    end
  end
end
