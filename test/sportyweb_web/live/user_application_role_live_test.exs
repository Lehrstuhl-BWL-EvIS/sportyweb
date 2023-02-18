defmodule SportywebWeb.UserApplicationRoleLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.RBAC.UserRoleFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_user_application_role(_) do
    user_application_role = user_application_role_fixture()
    %{user_application_role: user_application_role}
  end

  describe "Index" do
    setup [:create_user_application_role]

    test "lists all userapplicationroles", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/userapplicationroles")

      assert html =~ "Listing Userapplicationroles"
    end

    test "saves new user_application_role", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/userapplicationroles")

      assert index_live |> element("a", "New User application role") |> render_click() =~
               "New User application role"

      assert_patch(index_live, ~p"/userapplicationroles/new")

      assert index_live
             |> form("#user_application_role-form", user_application_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#user_application_role-form", user_application_role: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/userapplicationroles")

      assert html =~ "User application role created successfully"
    end

    test "updates user_application_role in listing", %{conn: conn, user_application_role: user_application_role} do
      {:ok, index_live, _html} = live(conn, ~p"/userapplicationroles")

      assert index_live |> element("#userapplicationroles-#{user_application_role.id} a", "Edit") |> render_click() =~
               "Edit User application role"

      assert_patch(index_live, ~p"/userapplicationroles/#{user_application_role}/edit")

      assert index_live
             |> form("#user_application_role-form", user_application_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#user_application_role-form", user_application_role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/userapplicationroles")

      assert html =~ "User application role updated successfully"
    end

    test "deletes user_application_role in listing", %{conn: conn, user_application_role: user_application_role} do
      {:ok, index_live, _html} = live(conn, ~p"/userapplicationroles")

      assert index_live |> element("#userapplicationroles-#{user_application_role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user_application_role-#{user_application_role.id}")
    end
  end

  describe "Show" do
    setup [:create_user_application_role]

    test "displays user_application_role", %{conn: conn, user_application_role: user_application_role} do
      {:ok, _show_live, html} = live(conn, ~p"/userapplicationroles/#{user_application_role}")

      assert html =~ "Show User application role"
    end

    test "updates user_application_role within modal", %{conn: conn, user_application_role: user_application_role} do
      {:ok, show_live, _html} = live(conn, ~p"/userapplicationroles/#{user_application_role}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit User application role"

      assert_patch(show_live, ~p"/userapplicationroles/#{user_application_role}/show/edit")

      assert show_live
             |> form("#user_application_role-form", user_application_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#user_application_role-form", user_application_role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/userapplicationroles/#{user_application_role}")

      assert html =~ "User application role updated successfully"
    end
  end
end
