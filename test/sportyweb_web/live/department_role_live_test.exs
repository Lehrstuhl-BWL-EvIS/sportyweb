defmodule SportywebWeb.DepartmentRoleLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  @create_attrs %{name: "some other name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_department_role(_) do
    department_role = department_role_fixture()
    %{department_role: department_role}
  end

  describe "Index" do
    setup [:create_department_role]

    test "lists all departmentroles", %{conn: conn, user: user, department_role: department_role} do
      {:error, _} = live(conn, ~p"/departmentroles")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/departmentroles")

      assert html =~ "Listing Departmentroles"
      assert html =~ department_role.name
    end

    test "saves new department_role", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/departmentroles")

      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, ~p"/departmentroles")

      assert index_live |> element("a", "New Department role") |> render_click() =~
               "New Department role"

      assert_patch(index_live, ~p"/departmentroles/new")

      assert index_live
             |> form("#department_role-form", department_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#department_role-form", department_role: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/departmentroles")

      assert html =~ "Department role created successfully"
      assert html =~ "some name"
    end

    test "updates department_role in listing", %{conn: conn, user: user, department_role: department_role} do
      {:error, _} = live(conn, ~p"/departmentroles")

      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, ~p"/departmentroles")

      assert index_live |> element("#departmentroles-#{department_role.id} a", "Edit") |> render_click() =~
               "Edit Department role"

      assert_patch(index_live, ~p"/departmentroles/#{department_role}/edit")

      assert index_live
             |> form("#department_role-form", department_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#department_role-form", department_role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/departmentroles")

      assert html =~ "Department role updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes department_role in listing", %{conn: conn, user: user, department_role: department_role} do
      {:error, _} = live(conn, ~p"/departmentroles")

      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, ~p"/departmentroles")

      assert index_live |> element("#departmentroles-#{department_role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#department_role-#{department_role.id}")
    end
  end

  describe "Show" do
    setup [:create_department_role]

    test "displays department_role", %{conn: conn, user: user, department_role: department_role} do
      {:error, _} = live(conn, ~p"/departmentroles")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/departmentroles/#{department_role}")

      assert html =~ "Show Department role"
      assert html =~ department_role.name
    end

    test "updates department_role within modal", %{conn: conn, user: user, department_role: department_role} do
      {:error, _} = live(conn, ~p"/departmentroles")

      conn = conn |> log_in_user(user)
      {:ok, show_live, _html} = live(conn, ~p"/departmentroles/#{department_role}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Department role"

      assert_patch(show_live, ~p"/departmentroles/#{department_role}/show/edit")

      assert show_live
             |> form("#department_role-form", department_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#department_role-form", department_role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/departmentroles/#{department_role}")

      assert html =~ "Department role updated successfully"
      assert html =~ "some updated name"
    end
  end
end
