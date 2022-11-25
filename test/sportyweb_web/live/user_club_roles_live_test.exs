defmodule SportywebWeb.UserClubRolesLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccessControlFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_user_club_roles(_) do
    user_club_roles = user_club_roles_fixture()
    %{user_club_roles: user_club_roles}
  end

  describe "Index" do
    setup [:create_user_club_roles]

    test "lists all userclubroles", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/userclubroles")

      assert html =~ "Listing Userclubroles"
    end

    test "saves new user_club_roles", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/userclubroles")

      assert index_live |> element("a", "New User club roles") |> render_click() =~
               "New User club roles"

      assert_patch(index_live, ~p"/userclubroles/new")

      assert index_live
             |> form("#user_club_roles-form", user_club_roles: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#user_club_roles-form", user_club_roles: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/userclubroles")

      assert html =~ "User club roles created successfully"
    end

    test "updates user_club_roles in listing", %{conn: conn, user_club_roles: user_club_roles} do
      {:ok, index_live, _html} = live(conn, ~p"/userclubroles")

      assert index_live |> element("#userclubroles-#{user_club_roles.id} a", "Edit") |> render_click() =~
               "Edit User club roles"

      assert_patch(index_live, ~p"/userclubroles/#{user_club_roles}/edit")

      assert index_live
             |> form("#user_club_roles-form", user_club_roles: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#user_club_roles-form", user_club_roles: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/userclubroles")

      assert html =~ "User club roles updated successfully"
    end

    test "deletes user_club_roles in listing", %{conn: conn, user_club_roles: user_club_roles} do
      {:ok, index_live, _html} = live(conn, ~p"/userclubroles")

      assert index_live |> element("#userclubroles-#{user_club_roles.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user_club_roles-#{user_club_roles.id}")
    end
  end

  describe "Show" do
    setup [:create_user_club_roles]

    test "displays user_club_roles", %{conn: conn, user_club_roles: user_club_roles} do
      {:ok, _show_live, html} = live(conn, ~p"/userclubroles/#{user_club_roles}")

      assert html =~ "Show User club roles"
    end

    test "updates user_club_roles within modal", %{conn: conn, user_club_roles: user_club_roles} do
      {:ok, show_live, _html} = live(conn, ~p"/userclubroles/#{user_club_roles}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit User club roles"

      assert_patch(show_live, ~p"/userclubroles/#{user_club_roles}/show/edit")

      assert show_live
             |> form("#user_club_roles-form", user_club_roles: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#user_club_roles-form", user_club_roles: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/userclubroles/#{user_club_roles}")

      assert html =~ "User club roles updated successfully"
    end
  end
end
