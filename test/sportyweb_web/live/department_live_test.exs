defmodule SportywebWeb.DepartmentLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  @create_attrs %{created_at: ~D[2022-11-05], name: "some name", type: "some type"}
  @update_attrs %{created_at: ~D[2022-11-06], name: "some updated name", type: "some updated type"}
  @invalid_attrs %{created_at: nil, name: nil, type: nil}

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    %{user: user}
  end

  defp create_department(_) do
    department = department_fixture()
    %{department: department}
  end

  describe "Index" do
    setup [:create_department]

    test "lists all departments - redirect", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/departments")

      conn = conn |> log_in_user(user)
      {:ok, conn} =
        conn
        |> live(~p"/departments")
        |> follow_redirect(conn, ~p"/clubs")

      assert conn.resp_body =~ "Vereinsübersicht"
    end

    test "lists all departments", %{conn: conn, user: user, department: department} do
      {:error, _} = live(conn, ~p"/clubs/#{department.club_id}/departments")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/clubs/#{department.club_id}/departments")

      assert html =~ "Abteilungen"
      assert html =~ department.name
    end
  end

  describe "New/Edit" do
    setup [:create_department]

    test "saves new department", %{conn: conn, user: user} do
      club = club_fixture()

      {:error, _} = live(conn, ~p"/clubs/#{club}/departments/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/clubs/#{club}/departments/new")

      assert html =~ "Abteilung erstellen"

      assert new_live
              |> form("#department-form", department: @invalid_attrs)
              |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        new_live
        |> form("#department-form", department: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubs/#{club}/departments")

      assert html =~ "Abteilung erfolgreich erstellt"
      assert html =~ "some name"
    end

    test "updates department in listing", %{conn: conn, user: user, department: department} do
      {:error, _} = live(conn, ~p"/departments/#{department}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/departments/#{department}/edit")

      assert html =~ "Abteilung bearbeiten"

      assert edit_live
             |> form("#department-form", department: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#department-form", department: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/departments/#{department}")

      assert html =~ "Abteilung erfolgreich aktualisiert"
      assert html =~ "some updated name"
    end
  end

  describe "Show" do
    setup [:create_department]

    test "displays department", %{conn: conn, user: user, department: department} do
      {:error, _} = live(conn, ~p"/departments/#{department}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/departments/#{department}")

      assert html =~ "Abteilung:"
      assert html =~ department.name
    end
  end
end
