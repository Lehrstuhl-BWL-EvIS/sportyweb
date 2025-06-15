defmodule Sportyweb.LegalTest do
  use Sportyweb.DataCase, async: true

  alias Sportyweb.Legal

  describe "contracts" do
    alias Sportyweb.Legal.Contract

    import Sportyweb.FinanceFixtures
    import Sportyweb.LegalFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PersonalFixtures

    @invalid_attrs %{
      club_id: nil,
      contact_id: nil,
      fee_id: nil,
      signing_date: nil,
      start_date: nil
    }

    test "list_contracts/1 returns all contracts of a given club" do
      contract = contract_fixture()
      assert Legal.list_contracts(contract.club_id) == [contract]
    end

    test "list_contracts/2 returns all contracts of a given club with preloaded associations" do
      contract = contract_fixture()

      contracts = Legal.list_contracts(contract.club_id, [:club])
      assert List.first(contracts).club_id == contract.club_id
    end

    test "get_contract!/1 returns the contract with given id" do
      contract = contract_fixture()
      assert Legal.get_contract!(contract.id) == contract
    end

    test "get_contract!/2 returns the contract with given id and contains a preloaded club" do
      contract = contract_fixture()

      assert %Contract{} = Legal.get_contract!(contract.id, [:club])
      assert Legal.get_contract!(contract.id, [:club]).club.id == contract.club_id
    end

    test "create_contract/1 with valid data creates a contract" do
      club = club_fixture()
      contact = contact_fixture()
      fee = fee_fixture()

      valid_attrs = %{
        club_id: club.id,
        contact_id: contact.id,
        fee_id: fee.id,
        signing_date: ~D[2023-02-01],
        start_date: ~D[2023-03-01]
      }

      assert {:ok, %Contract{}} = Legal.create_contract(valid_attrs)
    end

    test "create_contract/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Legal.create_contract(@invalid_attrs)
    end

    test "update_contract/2 with valid data updates the contract" do
      contract = contract_fixture()
      update_attrs = %{}

      assert {:ok, %Contract{}} = Legal.update_contract(contract, update_attrs)
    end

    test "update_contract/2 with invalid data returns error changeset" do
      contract = contract_fixture()
      assert {:error, %Ecto.Changeset{}} = Legal.update_contract(contract, @invalid_attrs)
      assert contract == Legal.get_contract!(contract.id)
    end

    test "delete_contract/1 deletes the contract" do
      contract = contract_fixture()
      assert {:ok, %Contract{}} = Legal.delete_contract(contract)
      assert_raise Ecto.NoResultsError, fn -> Legal.get_contract!(contract.id) end
    end

    test "change_contract/1 returns a contract changeset" do
      contract = contract_fixture()
      assert %Ecto.Changeset{} = Legal.change_contract(contract)
    end
  end

  describe "memberships" do
    alias Sportyweb.Legal.Membership

    import Sportyweb.FinanceFixtures
    import Sportyweb.LegalFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PersonalFixtures

    @invalid_attrs %{
      club_id: nil,
      contact_id: nil,
      contract_id: nil
    }

    test "get_membership!/1 returns the membership with given id" do
      membership = membership_fixture()
      assert Legal.get_membership!(membership.id) == membership
    end

    test "get_membership!/2 returns the membership with given id and contains a preloaded club" do
      membership = membership_fixture()

      assert %Membership{} = Legal.get_membership!(membership.id, [:club])
      assert Legal.get_membership!(membership.id, [:club]).club.id == membership.club_id
    end

    test "create_membership/1 with valid data creates a membership" do
      contract = contract_fixture()

      valid_attrs = %{
        club_id: contract.club_id,
        contact_id: contract.contact_id,
        contract_id: contract.id,
        state: "ACTIVE"
      }

      assert {:ok, %Membership{}} = Legal.create_membership(valid_attrs)
    end

    test "create_membership/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Legal.create_membership(@invalid_attrs)
    end

    test "update_membership/2 with valid data updates the membership" do
      membership = membership_fixture()
      update_attrs = %{}

      assert {:ok, %Membership{}} = Legal.update_membership(membership, update_attrs)
    end

    test "update_membership/2 with invalid data returns error changeset" do
      membership = membership_fixture()
      assert {:error, %Ecto.Changeset{}} = Legal.update_membership(membership, @invalid_attrs)
      assert membership == Legal.get_membership!(membership.id)
    end

    test "delete_membership/1 deletes the membership" do
      membership = membership_fixture()
      assert {:ok, %Membership{}} = Legal.delete_membership(membership)
      assert_raise Ecto.NoResultsError, fn -> Legal.get_membership!(membership.id) end
    end

    test "change_membership/1 returns a membership changeset" do
      membership = membership_fixture()
      assert %Ecto.Changeset{} = Legal.change_membership(membership)
    end
  end

  describe "constitution" do
    alias Sportyweb.Legal.Constitution

    import Sportyweb.FinanceFixtures
    import Sportyweb.LegalFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PersonalFixtures

    @invalid_attrs %{
      club_id: nil,
      termination_interval: nil
    }

    test "get_constitution_of_club/2 returns the constitution of the given club and contains a preloaded club" do
      constitution = constitution_fixture()

      assert %Constitution{} = Legal.get_constitution_of_club(constitution.club_id, [:club])

      assert Legal.get_constitution_of_club(constitution.club_id, [:club]).club.id ==
               constitution.club_id
    end

    test "create_constitution/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Legal.create_constitution(@invalid_attrs)
    end

    test "create_constitution/1 with empty constitution returns a constitution changeset" do
      club = club_fixture()

      valid_attrs = %{
        club_id: club.id,
        membership_types: ["type1", "type2"],
        suspension_reasons: ["reason1", "reason2"],
        suspension_reason_mode: "optional",
        termination_notice_period: "P1D",
        termination_interval: "end_of_quarter",
        minimal_membership_duration: ""
      }

      assert {:ok, %Constitution{}} = Legal.create_constitution(valid_attrs)
    end

    test "change_constitution/1 returns a constitution changeset" do
      constitution = constitution_fixture()
      assert %Ecto.Changeset{} = Legal.change_constitution(constitution)
    end

    test "update_constitution/2 with valid data updates the constitution" do
      constitution = constitution_fixture()
      update_attrs = %{}

      assert {:ok, %Constitution{}} = Legal.update_constitution(constitution, update_attrs)
    end

    test "update_constitution/2 with invalid data returns error changeset" do
      constitution = constitution_fixture()
      assert {:error, %Ecto.Changeset{}} = Legal.update_constitution(constitution, @invalid_attrs)
    end

    test "Constitution.get_next_allowed_archiving_date/2" do
      date = ~D[2000-05-06]

      constitution = %Constitution{
        termination_interval: "",
        termination_notice_period: ""
      }

      assert date = Constitution.get_next_allowed_archiving_date(constitution, nil, date)

      constitution = %Constitution{
        termination_interval: "",
        termination_notice_period: "P5M"
      }

      assert ~D[2000-10-06] =
               Constitution.get_next_allowed_archiving_date(constitution, nil, date)

      constitution = %Constitution{
        termination_interval: "end_of_half_year",
        termination_notice_period: ""
      }

      assert ~D[2000-06-30] =
               Constitution.get_next_allowed_archiving_date(constitution, nil, date)

      constitution = %Constitution{
        termination_interval: "end_of_half_year",
        termination_notice_period: "P5M"
      }

      assert ~D[2000-12-31] =
               Constitution.get_next_allowed_archiving_date(constitution, nil, date)
    end
  end
end
