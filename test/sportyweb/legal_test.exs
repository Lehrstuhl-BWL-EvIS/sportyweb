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

    test "list_contracts/3 without filter returns all contracts in correct order" do
      club = club_fixture()
      first_contract = contract_fixture(%{signing_date: ~D[2000-02-15], start_date: ~D[2000-02-15], club_id: club.id})
      middle_contract = contract_fixture(%{signing_date: ~D[2000-02-15], start_date: ~D[2001-02-15], club_id: club.id})
      last_contract = contract_fixture(%{signing_date: ~D[2000-02-15], start_date: ~D[2003-02-15], club_id: club.id})

      contracts = Legal.list_contracts(club.id, [asc: :start_date], nil)
      assert contracts == [first_contract, middle_contract, last_contract]

      contracts = Legal.list_contracts(club.id, [desc: :start_date], nil)
      assert contracts == [last_contract, middle_contract, first_contract]
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
end
