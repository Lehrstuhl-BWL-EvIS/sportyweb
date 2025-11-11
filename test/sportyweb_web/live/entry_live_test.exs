defmodule SportywebWeb.EntryLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountingFixtures

  @create_attrs %{type: "some type"}
  @update_attrs %{type: "some updated type"}
  @invalid_attrs %{type: nil}

  defp create_entry(_) do
    entry = entry_fixture()
    %{entry: entry}
  end

  describe "Index" do
    setup [:create_entry]

    test "lists all entries", %{conn: conn, entry: entry} do
      {:ok, _index_live, html} = live(conn, ~p"/entries")

      assert html =~ "Listing Entries"
      assert html =~ entry.type
    end

    test "saves new entry", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/entries")

      assert index_live |> element("a", "New Entry") |> render_click() =~
               "New Entry"

      assert_patch(index_live, ~p"/entries/new")

      assert index_live
             |> form("#entry-form", entry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#entry-form", entry: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/entries")

      html = render(index_live)
      assert html =~ "Entry created successfully"
      assert html =~ "some type"
    end

    test "updates entry in listing", %{conn: conn, entry: entry} do
      {:ok, index_live, _html} = live(conn, ~p"/entries")

      assert index_live |> element("#entries-#{entry.id} a", "Edit") |> render_click() =~
               "Edit Entry"

      assert_patch(index_live, ~p"/entries/#{entry}/edit")

      assert index_live
             |> form("#entry-form", entry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#entry-form", entry: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/entries")

      html = render(index_live)
      assert html =~ "Entry updated successfully"
      assert html =~ "some updated type"
    end

    test "deletes entry in listing", %{conn: conn, entry: entry} do
      {:ok, index_live, _html} = live(conn, ~p"/entries")

      assert index_live |> element("#entries-#{entry.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#entries-#{entry.id}")
    end
  end

  describe "Show" do
    setup [:create_entry]

    test "displays entry", %{conn: conn, entry: entry} do
      {:ok, _show_live, html} = live(conn, ~p"/entries/#{entry}")

      assert html =~ "Show Entry"
      assert html =~ entry.type
    end

    test "updates entry within modal", %{conn: conn, entry: entry} do
      {:ok, show_live, _html} = live(conn, ~p"/entries/#{entry}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Entry"

      assert_patch(show_live, ~p"/entries/#{entry}/show/edit")

      assert show_live
             |> form("#entry-form", entry: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#entry-form", entry: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/entries/#{entry}")

      html = render(show_live)
      assert html =~ "Entry updated successfully"
      assert html =~ "some updated type"
    end
  end
end
