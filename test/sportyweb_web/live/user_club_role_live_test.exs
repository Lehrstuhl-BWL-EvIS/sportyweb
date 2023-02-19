defmodule SportywebWeb.UserClubRoleLiveTest do
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

  defp create_user_club_role(_) do
    user = user_fixture()
    club = club_fixture()
    clubrole = club_role_fixture()
    user_club_role = user_club_role_fixture(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole.id})

    %{user_club_role: user_club_role}
  end

  describe "Index" do
    setup [:create_user_club_role]

    test "lists all userclubroles", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/userclubroles")

      conn = conn |> log_in_user(user)
      {:ok, _index_live, html} = live(conn, ~p"/userclubroles")

      assert html =~ "Listing Userclubroles"
    end

    test "deletes user_club_role in listing", %{conn: conn, user: user, user_club_role: user_club_role} do
      {:error, _} = live(conn, ~p"/userclubroles")

      conn = conn |> log_in_user(user)
      {:ok, index_live, _html} = live(conn, ~p"/userclubroles")

      assert index_live |> element("#userclubroles-#{user_club_role.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user_club_role-#{user_club_role.id}")
    end
  end

  describe "Show" do
    setup [:create_user_club_role]

    test "displays user_club_role", %{conn: conn, user: user, user_club_role: user_club_role} do
      {:error, _} = live(conn, ~p"/userclubroles")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/userclubroles/#{user_club_role}")

      assert html =~ "Show User club role"
    end
  end
end
