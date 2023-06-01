defmodule Sportyweb.LegalTest do
  use Sportyweb.DataCase

  alias Sportyweb.Legal

  describe "contracts" do
    alias Sportyweb.Legal.Contract

    import Sportyweb.LegalFixtures

    @invalid_attrs %{}

    test "list_contracts/0 returns all contracts" do
      contract = contract_fixture()
      assert Legal.list_general_contracts(contract.club_id, "club") == [contract]
    end

    test "get_contract!/1 returns the contract with given id" do
      contract = contract_fixture()
      assert Legal.get_contract!(contract.id) == contract
    end

    test "create_contract/1 with valid data creates a contract" do
      club = club_fixture()
      valid_attrs = %{club_id: club.id}

      assert {:ok, %Contract{} = contract} = Legal.create_contract(valid_attrs)
    end

    test "create_contract/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Legal.create_contract(@invalid_attrs)
    end

    test "update_contract/2 with valid data updates the contract" do
      contract = contract_fixture()
      update_attrs = %{}

      assert {:ok, %Contract{} = contract} = Legal.update_contract(contract, update_attrs)
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
