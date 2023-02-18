defmodule SportywebWeb.ClubRoleLiveTest do
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

  defp create_club_role(_) do
    club_role = club_role_fixture()
    %{club_role: club_role}
  end

  describe "Index" do
    setup [:create_club_role]

    test "lists all clubroles", %{conn: conn, user: user, club_role: club_role} do
      {:error, _} = live(conn, ~p"/clubroles")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/clubroles")

      assert html =~ "Listing Clubroles"
      assert html =~ club_role.name
    end

    test "saves new club_role", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/clubroles")

      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, ~p"/clubroles")

      assert index_live |> element("a", "New Club role") |> render_click() =~
               "New Club role"

      assert_patch(index_live, ~p"/clubroles/new")

      assert index_live
             |> form("#club_role-form", club_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#club_role-form", club_role: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubroles")

      assert html =~ "Club role created successfully"
      assert html =~ "some name"
    end

    test "updates club_role in listing", %{conn: conn, user: user, club_role: club_role} do
      {:error, _} = live(conn, ~p"/clubroles")

      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, ~p"/clubroles")

      assert index_live |> element("#clubroles-#{club_role.id} a", "Edit") |> render_click() =~
               "Edit Club role"

      assert_patch(index_live, ~p"/clubroles/#{club_role}/edit")

      assert index_live
             |> form("#club_role-form", club_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#club_role-form", club_role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubroles")

      assert html =~ "Club role updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes club_role in listing", %{conn: conn, user: user, club_role: club_role} do
      {:error, _} = live(conn, ~p"/clubroles")

      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, ~p"/clubroles")

      assert index_live |> element("#clubroles-#{club_role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#club_role-#{club_role.id}")
    end
  end

  describe "Show" do
    setup [:create_club_role]

    test "displays club_role", %{conn: conn, user: user, club_role: club_role} do
      {:error, _} = live(conn, ~p"/clubroles")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/clubroles/#{club_role}")

      assert html =~ "Show Club role"
      assert html =~ club_role.name
    end

    test "updates club_role within modal", %{conn: conn, user: user, club_role: club_role} do
      {:error, _} = live(conn, ~p"/clubroles")

      conn = conn |> log_in_user(user)
      {:ok, show_live, _html} = live(conn, ~p"/clubroles/#{club_role}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Club role"

      assert_patch(show_live, ~p"/clubroles/#{club_role}/show/edit")

      assert show_live
             |> form("#club_role-form", club_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#club_role-form", club_role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/clubroles/#{club_role}")

      assert html =~ "Club role updated successfully"
      assert html =~ "some updated name"
    end
  end
end
