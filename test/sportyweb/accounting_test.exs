defmodule Sportyweb.AccountingTest do
  use Sportyweb.DataCase, async: true

  alias Sportyweb.Accounting

  describe "transactions" do
    alias Sportyweb.Accounting.Transaction
    alias Sportyweb.Legal

    import Sportyweb.AccountingFixtures
    import Sportyweb.LegalFixtures

    @invalid_attrs %{
      amount: nil,
      creation_date: nil,
      name: nil,
      payment_date: ""
    }

    test "list_transactions/1 returns all transactions of a given club" do
      transaction = transaction_fixture()
      contract = Legal.get_contract!(transaction.contract_id)
      assert Accounting.list_transactions(contract.club_id) == [transaction]
    end

    test "list_transactions/2 returns all contracts of a given club with preloaded associations" do
      transaction = transaction_fixture()
      contract = Legal.get_contract!(transaction.contract_id)

      transactions = Accounting.list_transactions(contract.club_id, [:contract])
      assert List.first(transactions).contract_id == contract.id
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Accounting.get_transaction!(transaction.id) == transaction
    end

    test "get_transaction!/2 returns the contract with given id and contains a preloaded club" do
      transaction = transaction_fixture()

      assert %Transaction{} = Accounting.get_transaction!(transaction.id, [:contract])

      assert Accounting.get_transaction!(transaction.id, [:contract]).contract.id ==
               transaction.contract_id
    end

    test "create_transaction/1 with valid data creates a transaction" do
      contract = contract_fixture()

      valid_attrs = %{
        contract_id: contract.id,
        amount: "42 €",
        creation_date: ~D[2023-06-04],
        name: "some name",
        payment_date: ~D[2023-06-04]
      }

      assert {:ok, %Transaction{} = transaction} = Accounting.create_transaction(valid_attrs)
      assert transaction.amount == Money.new(:EUR, 42)
      assert transaction.creation_date == ~D[2023-06-04]
      assert transaction.name == "some name"
      assert transaction.payment_date == ~D[2023-06-04]
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounting.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()

      update_attrs = %{
        amount: "43 €",
        creation_date: ~D[2023-06-05],
        name: "some updated name",
        payment_date: ~D[2023-06-05]
      }

      assert {:ok, %Transaction{} = transaction} =
               Accounting.update_transaction(transaction, update_attrs)

      assert transaction.amount == Money.new(:EUR, 43)
      assert transaction.creation_date == ~D[2023-06-05]
      assert transaction.name == "some updated name"
      assert transaction.payment_date == ~D[2023-06-05]
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounting.update_transaction(transaction, @invalid_attrs)

      assert transaction == Accounting.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Accounting.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Accounting.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Accounting.change_transaction(transaction)
    end
  end
end
