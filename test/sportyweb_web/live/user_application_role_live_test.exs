defmodule SportywebWeb.UserApplicationRoleLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_user_application_role(_) do
    user = user_fixture()
    applicationrole = application_role_fixture(%{name: "some name"})
    user_application_role = user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user_application_role: user_application_role}
  end

  describe "Index" do
    setup [:create_user_application_role]

    test "lists all userapplicationroles", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/userapplicationroles")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/userapplicationroles")

      assert html =~ "Listing Userapplicationroles"
    end

    test "deletes user_application_role in listing", %{conn: conn, user: user, user_application_role: user_application_role} do
      {:error, _} = live(conn, ~p"/userapplicationroles")

      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, ~p"/userapplicationroles")

      assert index_live |> element("#userapplicationroles-#{user_application_role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user_application_role-#{user_application_role.id}")
    end
  end

  describe "Show" do
    setup [:create_user_application_role]

    test "displays user_application_role", %{conn: conn, user: user, user_application_role: user_application_role} do
      {:error, _} = live(conn, ~p"/userapplicationroles")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/userapplicationroles/#{user_application_role}")

      assert html =~ "Show User application role"
    end
  end
end
