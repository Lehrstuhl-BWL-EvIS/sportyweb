defmodule SportywebWeb.DepartmentLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.OrganizationFixtures

  @create_attrs %{created_at: "2022-11-5", name: "some name", type: "some type"}
  @update_attrs %{created_at: "2022-11-6", name: "some updated name", type: "some updated type"}
  @invalid_attrs %{created_at: nil, name: nil, type: nil}

  defp create_department(_) do
    department = department_fixture()
    %{department: department}
  end

  describe "Index" do
    setup [:create_department]

    test "lists all departments", %{conn: conn, department: department} do
      {:ok, _index_live, html} = live(conn, ~p"/departments")

      assert html =~ "Listing Departments"
      assert html =~ department.name
    end

    test "saves new department", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/departments")

      assert index_live |> element("a", "New Department") |> render_click() =~
               "New Department"

      assert_patch(index_live, ~p"/departments/new")

      assert index_live
             |> form("#department-form", department: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#department-form", department: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/departments")

      assert html =~ "Department created successfully"
      assert html =~ "some name"
    end

    test "updates department in listing", %{conn: conn, department: department} do
      {:ok, index_live, _html} = live(conn, ~p"/departments")

      assert index_live |> element("#departments-#{department.id} a", "Edit") |> render_click() =~
               "Edit Department"

      assert_patch(index_live, ~p"/departments/#{department}/edit")

      assert index_live
             |> form("#department-form", department: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#department-form", department: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/departments")

      assert html =~ "Department updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes department in listing", %{conn: conn, department: department} do
      {:ok, index_live, _html} = live(conn, ~p"/departments")

      assert index_live |> element("#departments-#{department.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#department-#{department.id}")
    end
  end

  describe "Show" do
    setup [:create_department]

    test "displays department", %{conn: conn, department: department} do
      {:ok, _show_live, html} = live(conn, ~p"/departments/#{department}")

      assert html =~ "Show Department"
      assert html =~ department.name
    end

    test "updates department within modal", %{conn: conn, department: department} do
      {:ok, show_live, _html} = live(conn, ~p"/departments/#{department}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Department"

      assert_patch(show_live, ~p"/departments/#{department}/show/edit")

      assert show_live
             |> form("#department-form", department: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#department-form", department: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/departments/#{department}")

      assert html =~ "Department updated successfully"
      assert html =~ "some updated name"
    end
  end
end
