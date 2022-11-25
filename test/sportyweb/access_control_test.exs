defmodule Sportyweb.AccessControlTest do
  use Sportyweb.DataCase

  alias Sportyweb.AccessControl

  describe "clubroles" do
    alias Sportyweb.AccessControl.ClubRole

    import Sportyweb.AccessControlFixtures

    @invalid_attrs %{name: nil}

    test "list_clubroles/0 returns all clubroles" do
      club_role = club_role_fixture()
      assert AccessControl.list_clubroles() == [club_role]
    end

    test "get_club_role!/1 returns the club_role with given id" do
      club_role = club_role_fixture()
      assert AccessControl.get_club_role!(club_role.id) == club_role
    end

    test "create_club_role/1 with valid data creates a club_role" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %ClubRole{} = club_role} = AccessControl.create_club_role(valid_attrs)
      assert club_role.name == "some name"
    end

    test "create_club_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AccessControl.create_club_role(@invalid_attrs)
    end

    test "update_club_role/2 with valid data updates the club_role" do
      club_role = club_role_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %ClubRole{} = club_role} = AccessControl.update_club_role(club_role, update_attrs)
      assert club_role.name == "some updated name"
    end

    test "update_club_role/2 with invalid data returns error changeset" do
      club_role = club_role_fixture()
      assert {:error, %Ecto.Changeset{}} = AccessControl.update_club_role(club_role, @invalid_attrs)
      assert club_role == AccessControl.get_club_role!(club_role.id)
    end

    test "delete_club_role/1 deletes the club_role" do
      club_role = club_role_fixture()
      assert {:ok, %ClubRole{}} = AccessControl.delete_club_role(club_role)
      assert_raise Ecto.NoResultsError, fn -> AccessControl.get_club_role!(club_role.id) end
    end

    test "change_club_role/1 returns a club_role changeset" do
      club_role = club_role_fixture()
      assert %Ecto.Changeset{} = AccessControl.change_club_role(club_role)
    end
  end

  describe "userclubroles" do
    alias Sportyweb.AccessControl.UserClubRoles

    import Sportyweb.AccessControlFixtures

    @invalid_attrs %{}

    test "list_userclubroles/0 returns all userclubroles" do
      user_club_roles = user_club_roles_fixture()
      assert AccessControl.list_userclubroles() == [user_club_roles]
    end

    test "get_user_club_roles!/1 returns the user_club_roles with given id" do
      user_club_roles = user_club_roles_fixture()
      assert AccessControl.get_user_club_roles!(user_club_roles.id) == user_club_roles
    end

    test "create_user_club_roles/1 with valid data creates a user_club_roles" do
      valid_attrs = %{}

      assert {:ok, %UserClubRoles{} = user_club_roles} = AccessControl.create_user_club_roles(valid_attrs)
    end

    test "create_user_club_roles/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AccessControl.create_user_club_roles(@invalid_attrs)
    end

    test "update_user_club_roles/2 with valid data updates the user_club_roles" do
      user_club_roles = user_club_roles_fixture()
      update_attrs = %{}

      assert {:ok, %UserClubRoles{} = user_club_roles} = AccessControl.update_user_club_roles(user_club_roles, update_attrs)
    end

    test "update_user_club_roles/2 with invalid data returns error changeset" do
      user_club_roles = user_club_roles_fixture()
      assert {:error, %Ecto.Changeset{}} = AccessControl.update_user_club_roles(user_club_roles, @invalid_attrs)
      assert user_club_roles == AccessControl.get_user_club_roles!(user_club_roles.id)
    end

    test "delete_user_club_roles/1 deletes the user_club_roles" do
      user_club_roles = user_club_roles_fixture()
      assert {:ok, %UserClubRoles{}} = AccessControl.delete_user_club_roles(user_club_roles)
      assert_raise Ecto.NoResultsError, fn -> AccessControl.get_user_club_roles!(user_club_roles.id) end
    end

    test "change_user_club_roles/1 returns a user_club_roles changeset" do
      user_club_roles = user_club_roles_fixture()
      assert %Ecto.Changeset{} = AccessControl.change_user_club_roles(user_club_roles)
    end
  end
end
