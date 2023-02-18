defmodule Sportyweb.RBAC.RoleTest do
  use Sportyweb.DataCase

  alias Sportyweb.RBAC.Role

  describe "clubroles" do
    alias Sportyweb.RBAC.Role.ClubRole

    import Sportyweb.RBAC.RoleFixtures

    @invalid_attrs %{name: nil}

    test "list_clubroles/0 returns all clubroles" do
      club_role = club_role_fixture()
      assert Role.list_clubroles() == [club_role]
    end

    test "get_club_role!/1 returns the club_role with given id" do
      club_role = club_role_fixture()
      assert Role.get_club_role!(club_role.id) == club_role
    end

    test "create_club_role/1 with valid data creates a club_role" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %ClubRole{} = club_role} = Role.create_club_role(valid_attrs)
      assert club_role.name == "some name"
    end

    test "create_club_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Role.create_club_role(@invalid_attrs)
    end

    test "update_club_role/2 with valid data updates the club_role" do
      club_role = club_role_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %ClubRole{} = club_role} = Role.update_club_role(club_role, update_attrs)
      assert club_role.name == "some updated name"
    end

    test "update_club_role/2 with invalid data returns error changeset" do
      club_role = club_role_fixture()
      assert {:error, %Ecto.Changeset{}} = Role.update_club_role(club_role, @invalid_attrs)
      assert club_role == Role.get_club_role!(club_role.id)
    end

    test "delete_club_role/1 deletes the club_role" do
      club_role = club_role_fixture()
      assert {:ok, %ClubRole{}} = Role.delete_club_role(club_role)
      assert_raise Ecto.NoResultsError, fn -> Role.get_club_role!(club_role.id) end
    end

    test "change_club_role/1 returns a club_role changeset" do
      club_role = club_role_fixture()
      assert %Ecto.Changeset{} = Role.change_club_role(club_role)
    end
  end

  describe "applicationroles" do
    alias Sportyweb.RBAC.Role.ApplicationRole

    import Sportyweb.RBAC.RoleFixtures

    @invalid_attrs %{name: nil}

    test "list_applicationroles/0 returns all applicationroles" do
      application_role = application_role_fixture()
      assert Role.list_applicationroles() == [application_role]
    end

    test "get_application_role!/1 returns the application_role with given id" do
      application_role = application_role_fixture()
      assert Role.get_application_role!(application_role.id) == application_role
    end

    test "create_application_role/1 with valid data creates a application_role" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %ApplicationRole{} = application_role} = Role.create_application_role(valid_attrs)
      assert application_role.name == "some name"
    end

    test "create_application_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Role.create_application_role(@invalid_attrs)
    end

    test "update_application_role/2 with valid data updates the application_role" do
      application_role = application_role_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %ApplicationRole{} = application_role} = Role.update_application_role(application_role, update_attrs)
      assert application_role.name == "some updated name"
    end

    test "update_application_role/2 with invalid data returns error changeset" do
      application_role = application_role_fixture()
      assert {:error, %Ecto.Changeset{}} = Role.update_application_role(application_role, @invalid_attrs)
      assert application_role == Role.get_application_role!(application_role.id)
    end

    test "delete_application_role/1 deletes the application_role" do
      application_role = application_role_fixture()
      assert {:ok, %ApplicationRole{}} = Role.delete_application_role(application_role)
      assert_raise Ecto.NoResultsError, fn -> Role.get_application_role!(application_role.id) end
    end

    test "change_application_role/1 returns a application_role changeset" do
      application_role = application_role_fixture()
      assert %Ecto.Changeset{} = Role.change_application_role(application_role)
    end
  end
end
