defmodule Sportyweb.RBAC.UserRoleTest do
  use Sportyweb.DataCase

  import Phoenix.LiveViewTest

  alias Sportyweb.RBAC.UserRole

  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures

  setup do
    %{user: user_fixture(), club: club_fixture(), clubrole: club_role_fixture()}
  end

  describe "userclubroles" do
    alias Sportyweb.RBAC.UserRole.UserClubRole

    import Sportyweb.RBAC.UserRoleFixtures

    @invalid_attrs %{user_id: 0, club_id: 0, clubrole_id: 0}

    test "list_userclubroles/0 returns all userclubroles", %{user: user, club: club, clubrole: clubrole} do
      user_club_role = user_club_role_fixture(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole.id})
      assert UserRole.list_userclubroles() == [user_club_role]
    end

    test "get_user_club_role!/1 returns the user_club_role with given id", %{user: user, club: club, clubrole: clubrole} do
      user_club_role = user_club_role_fixture(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole.id})
      assert UserRole.get_user_club_role!(user_club_role.id) == user_club_role
    end

    test "create_user_club_role/1 with valid data creates a user_club_role", %{user: user, club: club, clubrole: clubrole} do
      valid_attrs = %{user_id: user.id, club_id: club.id, clubrole_id: clubrole.id}

      assert {:ok, %UserClubRole{} = user_club_role} = UserRole.create_user_club_role(valid_attrs)
    end

    test "create_user_club_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserRole.create_user_club_role(@invalid_attrs)
    end

    test "update_user_club_role/2 with valid data updates the user_club_role", %{user: user, club: club, clubrole: clubrole} do
      user_club_role = user_club_role_fixture(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole.id})
      update_attrs = %{}

      assert {:ok, %UserClubRole{} = user_club_role} = UserRole.update_user_club_role(user_club_role, update_attrs)
    end

    test "update_user_club_role/2 with invalid data returns error changeset", %{user: user, club: club, clubrole: clubrole} do
      user_club_role = user_club_role_fixture(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole.id})
      assert {:error, %Ecto.Changeset{}} = UserRole.update_user_club_role(user_club_role, @invalid_attrs)
      assert user_club_role == UserRole.get_user_club_role!(user_club_role.id)
    end

    test "delete_user_club_role/1 deletes the user_club_role", %{user: user, club: club, clubrole: clubrole} do
      user_club_role = user_club_role_fixture(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole.id})
      assert {:ok, %UserClubRole{}} = UserRole.delete_user_club_role(user_club_role)
      assert_raise Ecto.NoResultsError, fn -> UserRole.get_user_club_role!(user_club_role.id) end
    end

    test "change_user_club_role/1 returns a user_club_role changeset", %{user: user, club: club, clubrole: clubrole} do
      user_club_role = user_club_role_fixture(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole.id})
      assert %Ecto.Changeset{} = UserRole.change_user_club_role(user_club_role)
    end
  end

  describe "userapplicationroles" do
    alias Sportyweb.RBAC.UserRole.UserApplicationRole

    import Sportyweb.RBAC.UserRoleFixtures

    @invalid_attrs %{}

    test "list_userapplicationroles/0 returns all userapplicationroles" do
      user_application_role = user_application_role_fixture()
      assert UserRole.list_userapplicationroles() == [user_application_role]
    end

    test "get_user_application_role!/1 returns the user_application_role with given id" do
      user_application_role = user_application_role_fixture()
      assert UserRole.get_user_application_role!(user_application_role.id) == user_application_role
    end

    test "create_user_application_role/1 with valid data creates a user_application_role" do
      valid_attrs = %{}

      assert {:ok, %UserApplicationRole{} = user_application_role} = UserRole.create_user_application_role(valid_attrs)
    end

    test "create_user_application_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserRole.create_user_application_role(@invalid_attrs)
    end

    test "update_user_application_role/2 with valid data updates the user_application_role" do
      user_application_role = user_application_role_fixture()
      update_attrs = %{}

      assert {:ok, %UserApplicationRole{} = user_application_role} = UserRole.update_user_application_role(user_application_role, update_attrs)
    end

    test "update_user_application_role/2 with invalid data returns error changeset" do
      user_application_role = user_application_role_fixture()
      assert {:error, %Ecto.Changeset{}} = UserRole.update_user_application_role(user_application_role, @invalid_attrs)
      assert user_application_role == UserRole.get_user_application_role!(user_application_role.id)
    end

    test "delete_user_application_role/1 deletes the user_application_role" do
      user_application_role = user_application_role_fixture()
      assert {:ok, %UserApplicationRole{}} = UserRole.delete_user_application_role(user_application_role)
      assert_raise Ecto.NoResultsError, fn -> UserRole.get_user_application_role!(user_application_role.id) end
    end

    test "change_user_application_role/1 returns a user_application_role changeset" do
      user_application_role = user_application_role_fixture()
      assert %Ecto.Changeset{} = UserRole.change_user_application_role(user_application_role)
    end
  end
end
