defmodule Sportyweb.OrganizationTest do
  use Sportyweb.DataCase

  alias Sportyweb.Organization

  describe "clubs" do
    alias Sportyweb.Organization.Club
    alias Sportyweb.Organization.ClubContract

    import Sportyweb.LegalFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PolymorphicFixtures

    @invalid_attrs %{
      name: nil,
      reference_number: nil,
      description: nil,
      website_url: nil,
      foundation_date: nil
    }

    test "list_clubs/0 returns all clubs" do
      club = club_fixture()
      assert List.first(Organization.list_clubs()).id == club.id
    end

    test "list_clubs/1 returns all clubs with preloaded associations" do
      club = club_fixture()
      assert Organization.list_clubs([:emails, :financial_data, :notes, :phones]) == [club]
    end

    test "get_club!/1 returns the club with given id" do
      club = club_fixture()
      assert Organization.get_club!(club.id).id == club.id
    end

    test "get_club!/2 returns the club with given id and contains preloaded associations" do
      club = club_fixture()
      assert Organization.get_club!(club.id, [:emails, :financial_data, :notes, :phones]) == club
    end

    test "create_club/1 with valid data creates a club" do
      valid_attrs = %{
        description: "some description",
        foundation_date: ~D[2022-11-05],
        name: "some name",
        reference_number: "some reference_number",
        website_url: "some website_url",
        emails: [email_attrs()],
        financial_data: [financial_data_attrs()],
        notes: [note_attrs()],
        phones: [phone_attrs()]
      }

      assert {:ok, %Club{} = club} = Organization.create_club(valid_attrs)
      assert club.description == "some description"
      assert club.foundation_date == ~D[2022-11-05]
      assert club.name == "some name"
      assert club.reference_number == "some reference_number"
      assert club.website_url == "some website_url"
    end

    test "create_club/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organization.create_club(@invalid_attrs)
    end

    test "update_club/2 with valid data updates the club" do
      club = club_fixture()

      update_attrs = %{
        description: "some updated description",
        foundation_date: ~D[2022-11-06],
        name: "some updated name",
        reference_number: "some updated reference_number",
        website_url: "some updated website_url"
      }

      assert {:ok, %Club{} = club} = Organization.update_club(club, update_attrs)
      assert club.description == "some updated description"
      assert club.foundation_date == ~D[2022-11-06]
      assert club.name == "some updated name"
      assert club.reference_number == "some updated reference_number"
      assert club.website_url == "some updated website_url"
    end

    test "update_club/2 with invalid data returns error changeset" do
      club = club_fixture()
      assert {:error, %Ecto.Changeset{}} = Organization.update_club(club, @invalid_attrs)
      assert club == Organization.get_club!(club.id, [:emails, :financial_data, :phones, :notes])
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

    test "create_club_contract/2 with valid data" do
      club = club_fixture()
      contract = contract_fixture()
      assert {:ok, %ClubContract{}} = Organization.create_club_contract(club, contract)
    end
  end

  describe "departments" do
    alias Sportyweb.Organization.Department
    alias Sportyweb.Organization.DepartmentContract
    alias Sportyweb.Organization.DepartmentFee

    import Sportyweb.FinanceFixtures
    import Sportyweb.LegalFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PolymorphicFixtures

    @invalid_attrs %{name: nil, reference_number: nil, description: nil, creation_date: nil}

    test "list_departments/1 returns all departments of a given club" do
      department = department_fixture()
      assert List.first(Organization.list_departments(department.club_id)).id == department.id
    end

    test "list_departments/2 returns all departments of a given club with preloaded data" do
      department = department_fixture()
      assert Organization.list_departments(department.club_id, [:emails, :notes, :phones]) == [department]
    end

    test "get_department!/1 returns the department with given id" do
      department = department_fixture()
      assert Organization.get_department!(department.id).id == department.id
    end

    test "get_department!/2 returns the department with given id and contains preloaded associations" do
      department = department_fixture()
      assert Organization.get_department!(department.id, [:emails, :notes, :phones]) == department
    end

    test "create_department/1 with valid data creates a department" do
      club = club_fixture()

      valid_attrs = %{
        club_id: club.id,
        creation_date: ~D[2022-11-05],
        description: "some description",
        name: "some name",
        reference_number: "some reference_number",
        emails: [email_attrs()],
        notes: [note_attrs()],
        phones: [phone_attrs()]
      }

      assert {:ok, %Department{} = department} = Organization.create_department(valid_attrs)
      assert department.creation_date == ~D[2022-11-05]
      assert department.description == "some description"
      assert department.name == "some name"
      assert department.reference_number == "some reference_number"
    end

    test "create_department/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organization.create_department(@invalid_attrs)
    end

    test "update_department/2 with valid data updates the department" do
      department = department_fixture()

      update_attrs = %{
        creation_date: ~D[2022-11-06],
        description: "some updated description",
        name: "some updated name",
        reference_number: "some updated reference_number"
      }

      assert {:ok, %Department{} = department} =
               Organization.update_department(department, update_attrs)

      assert department.creation_date == ~D[2022-11-06]
      assert department.description == "some updated description"
      assert department.name == "some updated name"
      assert department.reference_number == "some updated reference_number"
    end

    test "update_department/2 with invalid data returns error changeset" do
      department = department_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Organization.update_department(department, @invalid_attrs)

      assert department == Organization.get_department!(department.id, [:emails, :phones, :notes])
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

    test "create_department_contract/2 with valid data" do
      department = department_fixture()
      contract = contract_fixture()
      assert {:ok, %DepartmentContract{}} = Organization.create_department_contract(department, contract)
    end

    test "create_department_fee/2 with valid data" do
      department = department_fixture()
      fee = fee_fixture()
      assert {:ok, %DepartmentFee{}} = Organization.create_department_fee(department, fee)
    end
  end

  describe "groups" do
    alias Sportyweb.Organization.Group
    alias Sportyweb.Organization.GroupContract
    alias Sportyweb.Organization.GroupFee

    import Sportyweb.FinanceFixtures
    import Sportyweb.LegalFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PolymorphicFixtures

    @invalid_attrs %{name: nil, reference_number: nil, description: nil, creation_date: nil}

    test "list_groups/1 returns all groups of a given department" do
      group = group_fixture()
      assert List.first(Organization.list_groups(group.department_id)).id == group.id
    end

    test "list_groups/2 returns all contacts of a given department with preloaded associations" do
      group = group_fixture()
      assert Organization.list_groups(group.department_id, [:emails, :notes, :phones]) == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Organization.get_group!(group.id).id == group.id
    end

    test "get_group!/1 returns the group with given id and contains preloaded associations" do
      group = group_fixture()
      assert Organization.get_group!(group.id, [:emails, :notes, :phones]) == group
    end

    test "create_group/1 with valid data creates a group" do
      department = department_fixture()

      valid_attrs = %{
        department_id: department.id,
        creation_date: ~D[2023-02-11],
        description: "some description",
        name: "some name",
        reference_number: "some reference_number",
        emails: [email_attrs()],
        notes: [note_attrs()],
        phones: [phone_attrs()]
      }

      assert {:ok, %Group{} = group} = Organization.create_group(valid_attrs)
      assert group.creation_date == ~D[2023-02-11]
      assert group.description == "some description"
      assert group.name == "some name"
      assert group.reference_number == "some reference_number"
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organization.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()

      update_attrs = %{
        creation_date: ~D[2023-02-12],
        description: "some updated description",
        name: "some updated name",
        reference_number: "some updated reference_number"
      }

      assert {:ok, %Group{} = group} = Organization.update_group(group, update_attrs)
      assert group.creation_date == ~D[2023-02-12]
      assert group.description == "some updated description"
      assert group.name == "some updated name"
      assert group.reference_number == "some updated reference_number"
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Organization.update_group(group, @invalid_attrs)
      assert group == Organization.get_group!(group.id, [:emails, :phones, :notes])
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

    test "create_group_contract/2 with valid data" do
      group = group_fixture()
      contract = contract_fixture()
      assert {:ok, %GroupContract{}} = Organization.create_group_contract(group, contract)
    end

    test "create_group_fee/2 with valid data" do
      group = group_fixture()
      fee = fee_fixture()
      assert {:ok, %GroupFee{}} = Organization.create_group_fee(group, fee)
    end
  end
end
