defmodule SportywebWeb.UserDepartmentRoleLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_user_department_role(_) do
    user = user_fixture()
    department = department_fixture()
    departmentrole = department_role_fixture()
    user_department_role = user_department_role_fixture(%{user_id: user.id, department_id: department.id, departmentrole_id: departmentrole.id})

    %{user_department_role: user_department_role}
  end

  describe "Index" do
    setup [:create_user_department_role]

    test "lists all userdepartmentroles", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/userdepartmentroles")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/userdepartmentroles")

      assert html =~ "Listing Userdepartmentroles"
    end

    test "deletes user_department_role in listing", %{conn: conn, user: user, user_department_role: user_department_role} do
      {:error, _} = live(conn, ~p"/userdepartmentroles")

      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, ~p"/userdepartmentroles")

      assert index_live |> element("#userdepartmentroles-#{user_department_role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user_department_role-#{user_department_role.id}")
    end
  end

  describe "Show" do
    setup [:create_user_department_role]

    test "displays user_department_role", %{conn: conn, user: user, user_department_role: user_department_role} do
      {:error, _} = live(conn, ~p"/userdepartmentroles/#{user_department_role}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/userdepartmentroles/#{user_department_role}")

      assert html =~ "Show User department role"
    end
  end
end
