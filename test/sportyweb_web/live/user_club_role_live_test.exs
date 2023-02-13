defmodule SportywebWeb.UserClubRoleLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.RBAC.UserRoleFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_user_club_role(_) do
    user_club_role = user_club_role_fixture()
    %{user_club_role: user_club_role}
  end

  describe "Index" do
    setup [:create_user_club_role]

    test "lists all userclubroles", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/userclubroles")

      assert html =~ "Listing Userclubroles"
    end

    test "saves new user_club_role", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/userclubroles")

      assert index_live |> element("a", "New User club role") |> render_click() =~
               "New User club role"

      assert_patch(index_live, ~p"/userclubroles/new")

      assert index_live
             |> form("#user_club_role-form", user_club_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#user_club_role-form", user_club_role: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/userclubroles")

      assert html =~ "User club role created successfully"
    end

    test "updates user_club_role in listing", %{conn: conn, user_club_role: user_club_role} do
      {:ok, index_live, _html} = live(conn, ~p"/userclubroles")

      assert index_live |> element("#userclubroles-#{user_club_role.id} a", "Edit") |> render_click() =~
               "Edit User club role"

      assert_patch(index_live, ~p"/userclubroles/#{user_club_role}/edit")

      assert index_live
             |> form("#user_club_role-form", user_club_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#user_club_role-form", user_club_role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/userclubroles")

      assert html =~ "User club role updated successfully"
    end

    test "deletes user_club_role in listing", %{conn: conn, user_club_role: user_club_role} do
      {:ok, index_live, _html} = live(conn, ~p"/userclubroles")

      assert index_live |> element("#userclubroles-#{user_club_role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user_club_role-#{user_club_role.id}")
    end
  end

  describe "Show" do
    setup [:create_user_club_role]

    test "displays user_club_role", %{conn: conn, user_club_role: user_club_role} do
      {:ok, _show_live, html} = live(conn, ~p"/userclubroles/#{user_club_role}")

      assert html =~ "Show User club role"
    end

    test "updates user_club_role within modal", %{conn: conn, user_club_role: user_club_role} do
      {:ok, show_live, _html} = live(conn, ~p"/userclubroles/#{user_club_role}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit User club role"

      assert_patch(show_live, ~p"/userclubroles/#{user_club_role}/show/edit")

      assert show_live
             |> form("#user_club_role-form", user_club_role: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#user_club_role-form", user_club_role: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/userclubroles/#{user_club_role}")

      assert html =~ "User club role updated successfully"
    end
  end
end
