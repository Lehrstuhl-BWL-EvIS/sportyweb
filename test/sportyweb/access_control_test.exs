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
    alias Sportyweb.AccessControl.UserClubRole

    import Sportyweb.AccessControlFixtures

    @invalid_attrs %{}

    test "list_userclubroles/0 returns all userclubroles" do
      user_club_role = user_club_role_fixture()
      assert AccessControl.list_userclubroles() == [user_club_role]
    end

    test "get_user_club_role!/1 returns the user_club_role with given id" do
      user_club_role = user_club_role_fixture()
      assert AccessControl.get_user_club_role!(user_club_role.id) == user_club_role
    end

    test "create_user_club_role/1 with valid data creates a user_club_role" do
      valid_attrs = %{}

      assert {:ok, %UserClubRole{} = user_club_role} = AccessControl.create_user_club_role(valid_attrs)
    end

    test "create_user_club_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AccessControl.create_user_club_role(@invalid_attrs)
    end

    test "update_user_club_role/2 with valid data updates the user_club_role" do
      user_club_role = user_club_role_fixture()
      update_attrs = %{}

      assert {:ok, %UserClubRole{} = user_club_role} = AccessControl.update_user_club_role(user_club_role, update_attrs)
    end

    test "update_user_club_role/2 with invalid data returns error changeset" do
      user_club_role = user_club_role_fixture()
      assert {:error, %Ecto.Changeset{}} = AccessControl.update_user_club_role(user_club_role, @invalid_attrs)
      assert user_club_role == AccessControl.get_user_club_role!(user_club_role.id)
    end

    test "delete_user_club_role/1 deletes the user_club_role" do
      user_club_role = user_club_role_fixture()
      assert {:ok, %UserClubRole{}} = AccessControl.delete_user_club_role(user_club_role)
      assert_raise Ecto.NoResultsError, fn -> AccessControl.get_user_club_role!(user_club_role.id) end
    end

    test "change_user_club_role/1 returns a user_club_role changeset" do
      user_club_role = user_club_role_fixture()
      assert %Ecto.Changeset{} = AccessControl.change_user_club_role(user_club_role)
    end
  end

  describe "applicationroles" do
    alias Sportyweb.AccessControl.ApplicationRole

    import Sportyweb.AccessControlFixtures

    @invalid_attrs %{name: nil}

    test "list_applicationroles/0 returns all applicationroles" do
      application_role = application_role_fixture()
      assert AccessControl.list_applicationroles() == [application_role]
    end

    test "get_application_role!/1 returns the application_role with given id" do
      application_role = application_role_fixture()
      assert AccessControl.get_application_role!(application_role.id) == application_role
    end

    test "create_application_role/1 with valid data creates a application_role" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %ApplicationRole{} = application_role} = AccessControl.create_application_role(valid_attrs)
      assert application_role.name == "some name"
    end

    test "create_application_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AccessControl.create_application_role(@invalid_attrs)
    end

    test "update_application_role/2 with valid data updates the application_role" do
      application_role = application_role_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %ApplicationRole{} = application_role} = AccessControl.update_application_role(application_role, update_attrs)
      assert application_role.name == "some updated name"
    end

    test "update_application_role/2 with invalid data returns error changeset" do
      application_role = application_role_fixture()
      assert {:error, %Ecto.Changeset{}} = AccessControl.update_application_role(application_role, @invalid_attrs)
      assert application_role == AccessControl.get_application_role!(application_role.id)
    end

    test "delete_application_role/1 deletes the application_role" do
      application_role = application_role_fixture()
      assert {:ok, %ApplicationRole{}} = AccessControl.delete_application_role(application_role)
      assert_raise Ecto.NoResultsError, fn -> AccessControl.get_application_role!(application_role.id) end
    end

    test "change_application_role/1 returns a application_role changeset" do
      application_role = application_role_fixture()
      assert %Ecto.Changeset{} = AccessControl.change_application_role(application_role)
    end
  end

  describe "userapplicationroles" do
    alias Sportyweb.AccessControl.UserApplicationRole

    import Sportyweb.AccessControlFixtures

    @invalid_attrs %{}

    test "list_userapplicationroles/0 returns all userapplicationroles" do
      user_application_role = user_application_role_fixture()
      assert AccessControl.list_userapplicationroles() == [user_application_role]
    end

    test "get_user_application_role!/1 returns the user_application_role with given id" do
      user_application_role = user_application_role_fixture()
      assert AccessControl.get_user_application_role!(user_application_role.id) == user_application_role
    end

    test "create_user_application_role/1 with valid data creates a user_application_role" do
      valid_attrs = %{}

      assert {:ok, %UserApplicationRole{} = user_application_role} = AccessControl.create_user_application_role(valid_attrs)
    end

    test "create_user_application_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AccessControl.create_user_application_role(@invalid_attrs)
    end

    test "update_user_application_role/2 with valid data updates the user_application_role" do
      user_application_role = user_application_role_fixture()
      update_attrs = %{}

      assert {:ok, %UserApplicationRole{} = user_application_role} = AccessControl.update_user_application_role(user_application_role, update_attrs)
    end

    test "update_user_application_role/2 with invalid data returns error changeset" do
      user_application_role = user_application_role_fixture()
      assert {:error, %Ecto.Changeset{}} = AccessControl.update_user_application_role(user_application_role, @invalid_attrs)
      assert user_application_role == AccessControl.get_user_application_role!(user_application_role.id)
    end

    test "delete_user_application_role/1 deletes the user_application_role" do
      user_application_role = user_application_role_fixture()
      assert {:ok, %UserApplicationRole{}} = AccessControl.delete_user_application_role(user_application_role)
      assert_raise Ecto.NoResultsError, fn -> AccessControl.get_user_application_role!(user_application_role.id) end
    end

    test "change_user_application_role/1 returns a user_application_role changeset" do
      user_application_role = user_application_role_fixture()
      assert %Ecto.Changeset{} = AccessControl.change_user_application_role(user_application_role)
    end
  end
end
