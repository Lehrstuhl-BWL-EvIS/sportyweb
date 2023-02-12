defmodule SportywebWeb.GroupLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.OrganizationFixtures

  @create_attrs %{created_at: "2023-2-11", description: "some description", name: "some name", reference_number: "some reference_number"}
  @update_attrs %{created_at: "2023-2-12", description: "some updated description", name: "some updated name", reference_number: "some updated reference_number"}
  @invalid_attrs %{created_at: nil, description: nil, name: nil, reference_number: nil}

  defp create_group(_) do
    group = group_fixture()
    %{group: group}
  end

  describe "Index" do
    setup [:create_group]

    test "lists all groups", %{conn: conn, group: group} do
      {:ok, _index_live, html} = live(conn, ~p"/groups")

      assert html =~ "Listing Groups"
      assert html =~ group.description
    end

    test "saves new group", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/groups")

      assert index_live |> element("a", "New Group") |> render_click() =~
               "New Group"

      assert_patch(index_live, ~p"/groups/new")

      assert index_live
             |> form("#group-form", group: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#group-form", group: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/groups")

      assert html =~ "Group created successfully"
      assert html =~ "some description"
    end

    test "updates group in listing", %{conn: conn, group: group} do
      {:ok, index_live, _html} = live(conn, ~p"/groups")

      assert index_live |> element("#groups-#{group.id} a", "Edit") |> render_click() =~
               "Edit Group"

      assert_patch(index_live, ~p"/groups/#{group}/edit")

      assert index_live
             |> form("#group-form", group: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#group-form", group: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/groups")

      assert html =~ "Group updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes group in listing", %{conn: conn, group: group} do
      {:ok, index_live, _html} = live(conn, ~p"/groups")

      assert index_live |> element("#groups-#{group.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#group-#{group.id}")
    end
  end

  describe "Show" do
    setup [:create_group]

    test "displays group", %{conn: conn, group: group} do
      {:ok, _show_live, html} = live(conn, ~p"/groups/#{group}")

      assert html =~ "Show Group"
      assert html =~ group.description
    end

    test "updates group within modal", %{conn: conn, group: group} do
      {:ok, show_live, _html} = live(conn, ~p"/groups/#{group}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Group"

      assert_patch(show_live, ~p"/groups/#{group}/show/edit")

      assert show_live
             |> form("#group-form", group: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#group-form", group: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/groups/#{group}")

      assert html =~ "Group updated successfully"
      assert html =~ "some updated description"
    end
  end
end
