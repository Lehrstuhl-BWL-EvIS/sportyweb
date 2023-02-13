defmodule Sportyweb.OrganizationTest do
  use Sportyweb.DataCase

  alias Sportyweb.Organization

  describe "clubs" do
    alias Sportyweb.Organization.Club

    import Sportyweb.OrganizationFixtures

    @invalid_attrs %{name: nil, reference_number: nil, description: nil, website_url: nil, founded_at: nil}

    test "list_clubs/0 returns all clubs" do
      club = club_fixture()
      assert Organization.list_clubs() == [club]
    end

    test "get_club!/1 returns the club with given id" do
      club = club_fixture()
      assert Organization.get_club!(club.id) == club
    end

    test "get_club!/2 returns the club with given id and contains a list of preloaded departments" do
      department = department_fixture()
      club_id = department.club_id

      assert %Club{} = Organization.get_club!(club_id, [:departments])
      assert Organization.get_club!(club_id, [:departments]).departments |> Enum.at(0) == department
    end

    test "create_club/1 with valid data creates a club" do
      valid_attrs = %{founded_at: ~D[2022-11-05], description: "some description", name: "some name", reference_number: "some reference_number", website_url: "some website_url"}

      assert {:ok, %Club{} = club} = Organization.create_club(valid_attrs)
      assert club.founded_at == ~D[2022-11-05]
      assert club.description == "some description"
      assert club.name == "some name"
      assert club.reference_number == "some reference_number"
      assert club.website_url == "some website_url"
    end

    test "create_club/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organization.create_club(@invalid_attrs)
    end

    test "update_club/2 with valid data updates the club" do
      club = club_fixture()
      update_attrs = %{founded_at: ~D[2022-11-06], description: "some updated description", name: "some updated name", reference_number: "some updated reference_number", website_url: "some updated website_url"}

      assert {:ok, %Club{} = club} = Organization.update_club(club, update_attrs)
      assert club.founded_at == ~D[2022-11-06]
      assert club.description == "some updated description"
      assert club.name == "some updated name"
      assert club.reference_number == "some updated reference_number"
      assert club.website_url == "some updated website_url"
    end

    test "update_club/2 with invalid data returns error changeset" do
      club = club_fixture()
      assert {:error, %Ecto.Changeset{}} = Organization.update_club(club, @invalid_attrs)
      assert club == Organization.get_club!(club.id)
    end

    test "delete_club/1 deletes the club" do
      club = club_fixture()
      assert {:ok, %Club{}} = Organization.delete_club(club)
      assert_raise Ecto.NoResultsError, fn -> Organization.get_club!(club.id) end
    end

    test "change_club/1 returns a club changeset" do
      club = club_fixture()
      assert %Ecto.Changeset{} = Organization.change_club(club)
    end
  end

  describe "departments" do
    alias Sportyweb.Organization.Department

    import Sportyweb.OrganizationFixtures

    @invalid_attrs %{name: nil, reference_number: nil, description: nil, created_at: nil}

    test "list_departments/1 returns all departments of a given club" do
      department = department_fixture()
      assert Organization.list_departments(department.club_id) == [department]
    end

    test "get_department!/1 returns the department with given id" do
      department = department_fixture()
      assert Organization.get_department!(department.id) == department
    end

    test "get_department!/2 returns the department with given id and contains a preloaded club" do
      department = department_fixture()

      assert %Department{} = Organization.get_department!(department.id, [:club])
      assert Organization.get_department!(department.id, [:club]).club.id == department.club_id
    end

    test "create_department/1 with valid data creates a department" do
      club = club_fixture()
      valid_attrs = %{club_id: club.id, created_at: ~D[2022-11-05], description: "some description", name: "some name", reference_number: "some reference_number"}

      assert {:ok, %Department{} = department} = Organization.create_department(valid_attrs)
      assert department.created_at == ~D[2022-11-05]
      assert department.description == "some description"
      assert department.name == "some name"
      assert department.reference_number == "some reference_number"
    end

    test "create_department/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organization.create_department(@invalid_attrs)
    end

    test "update_department/2 with valid data updates the department" do
      department = department_fixture()
      update_attrs = %{created_at: ~D[2022-11-06], description: "some updated description", name: "some updated name", reference_number: "some updated reference_number"}

      assert {:ok, %Department{} = department} = Organization.update_department(department, update_attrs)
      assert department.created_at == ~D[2022-11-06]
      assert department.description == "some updated description"
      assert department.name == "some updated name"
      assert department.reference_number == "some updated reference_number"
    end

    test "update_department/2 with invalid data returns error changeset" do
      department = department_fixture()
      assert {:error, %Ecto.Changeset{}} = Organization.update_department(department, @invalid_attrs)
      assert department == Organization.get_department!(department.id)
    end

    test "delete_department/1 deletes the department" do
      department = department_fixture()
      assert {:ok, %Department{}} = Organization.delete_department(department)
      assert_raise Ecto.NoResultsError, fn -> Organization.get_department!(department.id) end
    end

    test "change_department/1 returns a department changeset" do
      department = department_fixture()
      assert %Ecto.Changeset{} = Organization.change_department(department)
    end
  end

  describe "groups" do
    alias Sportyweb.Organization.Group

    import Sportyweb.OrganizationFixtures

    @invalid_attrs %{name: nil, reference_number: nil, description: nil, created_at: nil}

    test "list_groups/0 returns all groups" do
      group = group_fixture()
      assert Organization.list_groups(group.department_id) == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Organization.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      department = department_fixture()
      valid_attrs = %{department_id: department.id, created_at: ~D[2023-02-11], description: "some description", name: "some name", reference_number: "some reference_number"}

      assert {:ok, %Group{} = group} = Organization.create_group(valid_attrs)
      assert group.created_at == ~D[2023-02-11]
      assert group.description == "some description"
      assert group.name == "some name"
      assert group.reference_number == "some reference_number"
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organization.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()
      update_attrs = %{created_at: ~D[2023-02-12], description: "some updated description", name: "some updated name", reference_number: "some updated reference_number"}

      assert {:ok, %Group{} = group} = Organization.update_group(group, update_attrs)
      assert group.created_at == ~D[2023-02-12]
      assert group.description == "some updated description"
      assert group.name == "some updated name"
      assert group.reference_number == "some updated reference_number"
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Organization.update_group(group, @invalid_attrs)
      assert group == Organization.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Organization.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Organization.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Organization.change_group(group)
    end
  end
end
