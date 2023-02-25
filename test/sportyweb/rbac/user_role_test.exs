defmodule Sportyweb.RBAC.UserRoleTest do
  use Sportyweb.DataCase

  alias Sportyweb.RBAC.UserRole

  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures

  setup do
    %{user: user_fixture(), club: club_fixture(), clubrole: club_role_fixture(), applicationrole: application_role_fixture(), department: department_fixture(), departmentrole: department_role_fixture()}
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
      assert user_club_role.user_id == user.id
      assert user_club_role.club_id == club.id
      assert user_club_role.clubrole_id == clubrole.id
    end

    test "create_user_club_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserRole.create_user_club_role(@invalid_attrs)
    end

    test "update_user_club_role/2 with valid data updates the user_club_role", %{user: user, club: club, clubrole: clubrole} do
      user_club_role = user_club_role_fixture(%{user_id: user.id, club_id: club.id, clubrole_id: clubrole.id})
      new_clubrole = club_role_fixture(%{name: "new name"})
      update_attrs = %{clubrole_id: new_clubrole.id}

      assert {:ok, %UserClubRole{} = updated_user_club_role} = UserRole.update_user_club_role(user_club_role, update_attrs)
      assert updated_user_club_role.clubrole_id == new_clubrole.id
      assert updated_user_club_role.id == user_club_role.id
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

    @invalid_attrs %{user_id: 0, applicationrole_id: 0}

    test "list_userapplicationroles/0 returns all userapplicationroles", %{user: user, applicationrole: applicationrole} do
      user_application_role = user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})
      assert UserRole.list_userapplicationroles() == [user_application_role]
    end

    test "get_user_application_role!/1 returns the user_application_role with given id", %{user: user, applicationrole: applicationrole} do
      user_application_role = user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})
      assert UserRole.get_user_application_role!(user_application_role.id) == user_application_role
    end

    test "create_user_application_role/1 with valid data creates a user_application_role", %{user: user, applicationrole: applicationrole} do
      valid_attrs = %{user_id: user.id, applicationrole_id: applicationrole.id}

      assert {:ok, %UserApplicationRole{} = user_application_role} = UserRole.create_user_application_role(valid_attrs)
      assert user_application_role.user_id == user.id
      assert user_application_role.applicationrole_id == applicationrole.id
    end

    test "create_user_application_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserRole.create_user_application_role(@invalid_attrs)
    end

    test "update_user_application_role/2 with valid data updates the user_application_role", %{user: user, applicationrole: applicationrole} do
      user_application_role = user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})
      new_applicationrole = application_role_fixture(%{name: "new application role"})
      update_attrs = %{applicationrole_id: new_applicationrole.id}

      assert {:ok, %UserApplicationRole{} = updated_user_application_role} = UserRole.update_user_application_role(user_application_role, update_attrs)
      assert updated_user_application_role.applicationrole_id == new_applicationrole.id
      assert updated_user_application_role.id == user_application_role.id
    end

    test "update_user_application_role/2 with invalid data returns error changeset", %{user: user, applicationrole: applicationrole} do
      user_application_role = user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})
      assert {:error, %Ecto.Changeset{}} = UserRole.update_user_application_role(user_application_role, @invalid_attrs)
      assert user_application_role == UserRole.get_user_application_role!(user_application_role.id)
    end

    test "delete_user_application_role/1 deletes the user_application_role", %{user: user, applicationrole: applicationrole} do
      user_application_role = user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})
      assert {:ok, %UserApplicationRole{}} = UserRole.delete_user_application_role(user_application_role)
      assert_raise Ecto.NoResultsError, fn -> UserRole.get_user_application_role!(user_application_role.id) end
    end

    test "change_user_application_role/1 returns a user_application_role changeset", %{user: user, applicationrole: applicationrole} do
      user_application_role = user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})
      assert %Ecto.Changeset{} = UserRole.change_user_application_role(user_application_role)
    end
  end

  describe "userdepartmentroles" do
    alias Sportyweb.RBAC.UserRole.UserDepartmentRole

    import Sportyweb.RBAC.UserRoleFixtures

    @invalid_attrs %{user_id: 0, department_id: 0, departmentrole_id: 0}

    test "list_userdepartmentroles/0 returns all userdepartmentroles", %{user: user, department: department, departmentrole: departmentrole} do
      user_department_role = user_department_role_fixture(%{user_id: user.id, department_id: department.id, departmentrole_id: departmentrole.id})
      assert UserRole.list_userdepartmentroles() == [user_department_role]
    end

    test "get_user_department_role!/1 returns the user_department_role with given id", %{user: user, department: department, departmentrole: departmentrole} do
      user_department_role = user_department_role_fixture(%{user_id: user.id, department_id: department.id, departmentrole_id: departmentrole.id})
      assert UserRole.get_user_department_role!(user_department_role.id) == user_department_role
    end

    test "create_user_department_role/1 with valid data creates a user_department_role", %{user: user, department: department, departmentrole: departmentrole} do
      valid_attrs = %{user_id: user.id, department_id: department.id, departmentrole_id: departmentrole.id}

      assert {:ok, %UserDepartmentRole{} = user_department_role} = UserRole.create_user_department_role(valid_attrs)
      assert user_department_role.user_id == user.id
      assert user_department_role.department_id == department.id
      assert user_department_role.departmentrole_id == departmentrole.id
    end

    test "create_user_department_role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserRole.create_user_department_role(@invalid_attrs)
    end

    test "update_user_department_role/2 with valid data updates the user_department_role", %{user: user, department: department, departmentrole: departmentrole} do
      user_department_role = user_department_role_fixture(%{user_id: user.id, department_id: department.id, departmentrole_id: departmentrole.id})
      new_departmentrole = department_role_fixture(%{name: "new name"})
      update_attrs = %{departmentrole_id: new_departmentrole.id}

      assert {:ok, %UserDepartmentRole{} = updated_user_department_role} = UserRole.update_user_department_role(user_department_role, update_attrs)
      assert updated_user_department_role.departmentrole_id == new_departmentrole.id
      assert updated_user_department_role.id == user_department_role.id
    end

    test "update_user_department_role/2 with invalid data returns error changeset", %{user: user, department: department, departmentrole: departmentrole} do
      user_department_role = user_department_role_fixture(%{user_id: user.id, department_id: department.id, departmentrole_id: departmentrole.id})
      assert {:error, %Ecto.Changeset{}} = UserRole.update_user_department_role(user_department_role, @invalid_attrs)
      assert user_department_role == UserRole.get_user_department_role!(user_department_role.id)
    end

    test "delete_user_department_role/1 deletes the user_department_role", %{user: user, department: department, departmentrole: departmentrole} do
      user_department_role = user_department_role_fixture(%{user_id: user.id, department_id: department.id, departmentrole_id: departmentrole.id})
      assert {:ok, %UserDepartmentRole{}} = UserRole.delete_user_department_role(user_department_role)
      assert_raise Ecto.NoResultsError, fn -> UserRole.get_user_department_role!(user_department_role.id) end
    end

    test "change_user_department_role/1 returns a user_department_role changeset", %{user: user, department: department, departmentrole: departmentrole} do
      user_department_role = user_department_role_fixture(%{user_id: user.id, department_id: department.id, departmentrole_id: departmentrole.id})
      assert %Ecto.Changeset{} = UserRole.change_user_department_role(user_department_role)
    end
  end
end
