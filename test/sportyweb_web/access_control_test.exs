defmodule SportywebWeb.AccessControlTest do
  use SportywebWeb.ConnCase, async: true

  import Plug.Conn
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Accounts
  alias Sportyweb.Organization.Club

  alias Sportyweb.AccessControl
  alias Sportyweb.AccessControl.PolicyApplication
  alias Sportyweb.AccessControl.PolicyClub

  defp do_setup(_) do
    tester0 = Accounts.get_user_by_email("sportyweb_admin@tester.de")
    tester1 = Accounts.get_user_by_email("clubadmin@tester.de")
    tester2 = Accounts.get_user_by_email("clubsubadmin@tester.de")
    tester3 = Accounts.get_user_by_email("clubreadwritemember@tester.de")
    tester4 = Accounts.get_user_by_email("clubmember@tester.de")
    testers = [tester0, tester1, tester2, tester3, tester4]

    query_club = from club in Club,
      where: club.name == "1. FC Köln"

    club = query_club |> Repo.all() |> Enum.at(0)

    %{sportyweb_admin: tester0, club_admin: tester1, club_subadmin: tester2, club_member: tester4, club: club}
  end

  describe "PolicyClub functions" do
    setup [:do_setup]

    test "user with sportyweb admin role performs according to policy", %{sportyweb_admin: user, club: club} do
      assert user.email == "sportyweb_admin@tester.de"
      assert club.name == "1. FC Köln"
      assert PolicyApplication.is_sportyweb_admin(user) == true

      assert PolicyClub.can?(user, :index, club.id) == true
      assert PolicyClub.can?(user, :new, club.id) == true
      assert PolicyClub.can?(user, :edit, club.id) == true
      assert PolicyClub.can?(user, "delete", club.id) == true
      assert PolicyClub.can?(user, :show, club.id) == true
      assert PolicyClub.can?(user, :userrolemanagement, club.id) == true
    end

    test "user with higher role [club_admin] performs according to policy", %{club_admin: user, club: club} do
      assert user.email == "clubadmin@tester.de"
      assert club.name == "1. FC Köln"
      assert user |> PolicyClub.has_club_role(club.id) |> Enum.at(0) == "club_admin"
      assert PolicyApplication.is_sportyweb_admin(user) == false

      assert PolicyClub.can?(user, :index, club.id) == true
      assert PolicyClub.can?(user, :new, club.id) == false
      assert PolicyClub.can?(user, :edit, club.id) == true
      assert PolicyClub.can?(user, "delete", club.id) == true
      assert PolicyClub.can?(user, :show, club.id) == true
      assert PolicyClub.can?(user, :userrolemanagement, club.id) == true
    end

    test "user with lower role [club_member] performs according to policy", %{club_member: user, club: club} do
      assert user.email == "clubmember@tester.de"
      assert club.name == "1. FC Köln"
      assert user |> PolicyClub.has_club_role(club.id) |> Enum.at(0) == "club_member"
      assert PolicyApplication.is_sportyweb_admin(user) == false

      assert PolicyClub.can?(user, :index, club.id) == true
      assert PolicyClub.can?(user, :new, club.id) == false
      assert PolicyClub.can?(user, :edit, club.id) == false
      assert PolicyClub.can?(user, "delete", club.id) == false
      assert PolicyClub.can?(user, :show, club.id) == true
      assert PolicyClub.can?(user, :userrolemanagement, club.id) == false
    end

    test "get_club_roles_for_administration", %{club_admin: admin, club_subadmin: sub, club: club} do
      len = length(PolicyClub.get_club_roles_all)

      assert length(PolicyClub.get_club_roles_for_administration(admin, club.id)) == len
      assert length(PolicyClub.get_club_roles_for_administration(sub, club.id))   <  len
    end
  end

  describe "PolicyClub implementation" do
    setup [:do_setup]

    test "policy implemented correctly for user with sportyweb admin role", %{conn: conn, sportyweb_admin: user, club: club}do
      user_token = Accounts.generate_user_session_token(user)

      conn =
        conn
        |> Plug.Conn.assign(:current_user, user)
        |> Map.replace!(:secret_key_base, SportywebWeb.Endpoint.config(:secret_key_base))
        |> init_test_session(%{})
        |> put_session(:user_token, user_token)

      assert {:ok, index_view, _html}     = live(conn,  "/clubs")
      assert {:ok, _view, _html}          = live(conn,  "/clubs/new")
      assert {:ok, edit_view, _html}      = live(conn,  "/clubs/#{club.id}/edit")
      assert {:ok, _view, _html}          = live(conn,  "/clubs/#{club.id}")
      #assert {:ok, show_edit_view, _html} = live(conn,  "/clubs/#{club.id}/show/edit")
      assert {:ok, ucr_view, _html}       = live(conn,  "/clubs/#{club.id}/userrolemanagement")

      #assert edit_view |> element("#club-form a", "save") |> render_submit(%{"club" => club}) =~ "Listing Clubs"
      #assert show_edit_view |> element("club-form", "save") |> render_submit(%{"club" => club}) =~ "Listing Clubs"

      assert render_click(ucr_view, "save", %{}) =~ "Role settings saved succesfully"
      assert render_click(index_view, "delete", %{id: club.id}) =~ "Club deleted successfully"
    end

    test "policy implemented correctly for user with higher role [club_admin]", %{conn: conn, club_admin: user, club: club}do
      user_token = Accounts.generate_user_session_token(user)

      conn =
        conn
        |> Plug.Conn.assign(:current_user, user)
        |> Map.replace!(:secret_key_base, SportywebWeb.Endpoint.config(:secret_key_base))
        |> init_test_session(%{})
        |> put_session(:user_token, user_token)

      assert {:ok, index_view, _html}     = live(conn,  "/clubs")
      #assert {:error, _}                  = live(conn,  "/clubs/new")
      assert {:ok, edit_view, _html}      = live(conn,  "/clubs/#{club.id}/edit")
      assert {:ok, _view, _html}          = live(conn,  "/clubs/#{club.id}")
      #assert {:ok, show_edit_view, _html} = live(conn,  "/clubs/#{club.id}/show/edit")
      assert {:ok, ucr_view, _html}       = live(conn,  "/clubs/#{club.id}/userrolemanagement")

      #assert edit_view |> element("#club-form a", "save") |> render_submit(%{"club" => club}) =~ "Listing Clubs"
      #assert show_edit_view |> element("club-form", "save") |> render_submit(%{"club" => club}) =~ "Listing Clubs"

      assert render_click(ucr_view, "save", %{}) =~ "Role settings saved succesfully"
      assert render_click(index_view, "delete", %{id: club.id}) =~ "Club deleted successfully"
    end

    test "policy implemented correctly for user with lower role [club_member]", %{conn: conn, club_member: user, club: club}do
      user_token = Accounts.generate_user_session_token(user)

      conn =
        conn
        |> Plug.Conn.assign(:current_user, user)
        |> Map.replace!(:secret_key_base, SportywebWeb.Endpoint.config(:secret_key_base))
        |> init_test_session(%{})
        |> put_session(:user_token, user_token)

      assert {:ok, index_view, _html}   = live(conn,  "/clubs")
      #assert {:error, _}                = live(conn,  "/clubs/new")
      #assert {:error, _}                = live(conn,  "/clubs/#{club.id}/edit")
      assert {:ok, _view, _html}        = live(conn,  "/clubs/#{club.id}")
      #assert {:error, _}                = live(conn,  "/clubs/#{club.id}/show/edit")
      assert {:error, _}                = live(conn,  "/clubs/#{club.id}/userrolemanagement")

      assert render_click(index_view, "delete", %{id: club.id}) =~ "No permission to delete club"
    end
  end

end
