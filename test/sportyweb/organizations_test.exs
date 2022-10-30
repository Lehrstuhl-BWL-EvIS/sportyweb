defmodule Sportyweb.OrganizationsTest do
  use Sportyweb.DataCase

  alias Sportyweb.Organizations

  describe "clubs" do
    alias Sportyweb.Organizations.Club

    import Sportyweb.OrganizationsFixtures

    @invalid_attrs %{founded_at: nil, name: nil, reference_number: nil, website_url: nil}

    test "list_clubs/0 returns all clubs" do
      club = club_fixture()
      assert Organizations.list_clubs() == [club]
    end

    test "get_club!/1 returns the club with given id" do
      club = club_fixture()
      assert Organizations.get_club!(club.id) == club
    end

    test "create_club/1 with valid data creates a club" do
      valid_attrs = %{founded_at: ~D[2022-10-29], name: "some name", reference_number: "some reference_number", website_url: "some website_url"}

      assert {:ok, %Club{} = club} = Organizations.create_club(valid_attrs)
      assert club.founded_at == ~D[2022-10-29]
      assert club.name == "some name"
      assert club.reference_number == "some reference_number"
      assert club.website_url == "some website_url"
    end

    test "create_club/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_club(@invalid_attrs)
    end

    test "update_club/2 with valid data updates the club" do
      club = club_fixture()
      update_attrs = %{founded_at: ~D[2022-10-30], name: "some updated name", reference_number: "some updated reference_number", website_url: "some updated website_url"}

      assert {:ok, %Club{} = club} = Organizations.update_club(club, update_attrs)
      assert club.founded_at == ~D[2022-10-30]
      assert club.name == "some updated name"
      assert club.reference_number == "some updated reference_number"
      assert club.website_url == "some updated website_url"
    end

    test "update_club/2 with invalid data returns error changeset" do
      club = club_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizations.update_club(club, @invalid_attrs)
      assert club == Organizations.get_club!(club.id)
    end

    test "delete_club/1 deletes the club" do
      club = club_fixture()
      assert {:ok, %Club{}} = Organizations.delete_club(club)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_club!(club.id) end
    end

    test "change_club/1 returns a club changeset" do
      club = club_fixture()
      assert %Ecto.Changeset{} = Organizations.change_club(club)
    end
  end

  describe "departments" do
    alias Sportyweb.Organizations.Department

    import Sportyweb.OrganizationsFixtures

    @invalid_attrs %{created_at: nil, name: nil, type: nil}

    test "list_departments/0 returns all departments" do
      department = department_fixture()
      assert Organizations.list_departments() == [department]
    end

    test "get_department!/1 returns the department with given id" do
      department = department_fixture()
      assert Organizations.get_department!(department.id) == department
    end

    test "create_department/1 with valid data creates a department" do
      valid_attrs = %{created_at: ~D[2022-10-29], name: "some name", type: "some type"}

      assert {:ok, %Department{} = department} = Organizations.create_department(valid_attrs)
      assert department.created_at == ~D[2022-10-29]
      assert department.name == "some name"
      assert department.type == "some type"
    end

    test "create_department/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_department(@invalid_attrs)
    end

    test "update_department/2 with valid data updates the department" do
      department = department_fixture()
      update_attrs = %{created_at: ~D[2022-10-30], name: "some updated name", type: "some updated type"}

      assert {:ok, %Department{} = department} = Organizations.update_department(department, update_attrs)
      assert department.created_at == ~D[2022-10-30]
      assert department.name == "some updated name"
      assert department.type == "some updated type"
    end

    test "update_department/2 with invalid data returns error changeset" do
      department = department_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizations.update_department(department, @invalid_attrs)
      assert department == Organizations.get_department!(department.id)
    end

    test "delete_department/1 deletes the department" do
      department = department_fixture()
      assert {:ok, %Department{}} = Organizations.delete_department(department)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_department!(department.id) end
    end

    test "change_department/1 returns a department changeset" do
      department = department_fixture()
      assert %Ecto.Changeset{} = Organizations.change_department(department)
    end
  end
end
