defmodule SportywebWeb.UserDepartmentRoleLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.RBAC.UserRoleFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_user_department_role(_) do
    user_department_role = user_department_role_fixture()
    %{user_department_role: user_department_role}
  end

  describe "Index" do
    setup [:create_user_department_role]

    test "lists all userdepartmentroles", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/userdepartmentroles")

      assert html =~ "Listing Userdepartmentroles"
    end

    test "saves new user_department_role", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/userdepartmentroles")

      assert index_live |> element("a", "New User department role") |> render_click() =~
               "New User department role"

      assert_patch(index_live, ~p"/userdepartmentroles/new")

      assert index_live
             |> form("#user_department_role-form", user_department_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#user_department_role-form", user_department_role: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/userdepartmentroles")

      assert html =~ "User department role created successfully"
    end

    test "updates user_department_role in listing", %{conn: conn, user_department_role: user_department_role} do
      {:ok, index_live, _html} = live(conn, ~p"/userdepartmentroles")

      assert index_live |> element("#userdepartmentroles-#{user_department_role.id} a", "Edit") |> render_click() =~
               "Edit User department role"

      assert_patch(index_live, ~p"/userdepartmentroles/#{user_department_role}/edit")

      assert index_live
             |> form("#user_department_role-form", user_department_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#user_department_role-form", user_department_role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/userdepartmentroles")

      assert html =~ "User department role updated successfully"
    end

    test "deletes user_department_role in listing", %{conn: conn, user_department_role: user_department_role} do
      {:ok, index_live, _html} = live(conn, ~p"/userdepartmentroles")

      assert index_live |> element("#userdepartmentroles-#{user_department_role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user_department_role-#{user_department_role.id}")
    end
  end

  describe "Show" do
    setup [:create_user_department_role]

    test "displays user_department_role", %{conn: conn, user_department_role: user_department_role} do
      {:ok, _show_live, html} = live(conn, ~p"/userdepartmentroles/#{user_department_role}")

      assert html =~ "Show User department role"
    end

    test "updates user_department_role within modal", %{conn: conn, user_department_role: user_department_role} do
      {:ok, show_live, _html} = live(conn, ~p"/userdepartmentroles/#{user_department_role}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit User department role"

      assert_patch(show_live, ~p"/userdepartmentroles/#{user_department_role}/show/edit")

      assert show_live
             |> form("#user_department_role-form", user_department_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#user_department_role-form", user_department_role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/userdepartmentroles/#{user_department_role}")

      assert html =~ "User department role updated successfully"
    end
  end
end
