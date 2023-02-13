defmodule Sportyweb.RBAC.UserRoleTest do
  use Sportyweb.DataCase

  alias Sportyweb.RBAC.UserRole

  describe "userclubroles" do
    alias Sportyweb.RBAC.UserRole.UserClubRole

    import Sportyweb.RBAC.UserRoleFixtures

    @invalid_attrs %{}

    test "list_userclubroles/0 returns all userclubroles" do
      user_club_role = user_club_role_fixture()
      assert UserRole.list_userclubroles() == [user_club_role]
    end

    test "get_user_club_role!/1 returns the user_club_role with given id" do
      user_club_role = user_club_role_fixture()
      assert UserRole.get_user_club_role!(user_club_role.id) == user_club_role
    end

    test "create_user_club_role/1 with valid data creates a user_club_role" do
      valid_attrs = %{}

      assert {:ok, %UserClubRole{} = user_club_role} = UserRole.create_user_club_role(valid_attrs)
    end

    test "create_user_club_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserRole.create_user_club_role(@invalid_attrs)
    end

    test "update_user_club_role/2 with valid data updates the user_club_role" do
      user_club_role = user_club_role_fixture()
      update_attrs = %{}

      assert {:ok, %UserClubRole{} = user_club_role} = UserRole.update_user_club_role(user_club_role, update_attrs)
    end

    test "update_user_club_role/2 with invalid data returns error changeset" do
      user_club_role = user_club_role_fixture()
      assert {:error, %Ecto.Changeset{}} = UserRole.update_user_club_role(user_club_role, @invalid_attrs)
      assert user_club_role == UserRole.get_user_club_role!(user_club_role.id)
    end

    test "delete_user_club_role/1 deletes the user_club_role" do
      user_club_role = user_club_role_fixture()
      assert {:ok, %UserClubRole{}} = UserRole.delete_user_club_role(user_club_role)
      assert_raise Ecto.NoResultsError, fn -> UserRole.get_user_club_role!(user_club_role.id) end
    end

    test "change_user_club_role/1 returns a user_club_role changeset" do
      user_club_role = user_club_role_fixture()
      assert %Ecto.Changeset{} = UserRole.change_user_club_role(user_club_role)
    end
  end
end
