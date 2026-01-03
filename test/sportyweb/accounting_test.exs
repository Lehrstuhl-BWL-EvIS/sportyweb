defmodule Sportyweb.AccountingTest do
  use Sportyweb.DataCase, async: true

  alias Sportyweb.Accounting

  describe "transactions" do
    alias Sportyweb.Accounting.Transaction

    import Sportyweb.AccountingFixtures
    import Sportyweb.LegalFixtures
    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures

    @invalid_attrs %{
      amount: nil,
      creation_date: nil,
      name: nil,
      payment_date: "",
      type: "",
      receipt_number: 50
    }

    test "list_transactions/1 returns all transactions of a given club" do
      transaction = transaction_fixture()
      assert Accounting.list_transactions(transaction.club_id) == [transaction]
    end

    test "list_transactions/2 returns all transactions of a given club with preloaded associations" do
      transaction = transaction_fixture()

      transactions = Accounting.list_transactions(transaction.club_id, contract: :contact)
      assert List.first(transactions).club_id == transaction.club_id
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Accounting.get_transaction!(transaction.id) == transaction
    end

    test "get_transaction!/2 returns the transaction with given id and contains preloaded associations" do
      transaction = transaction_fixture()

      assert %Transaction{} =
               Accounting.get_transaction!(transaction.id, [:club, :contact, :contract])

      assert Accounting.get_transaction!(transaction.id, [
               :club,
               :contact,
               :contract,
               entries: [:account]
             ]).contract.id == transaction.contract_id

      assert Accounting.get_transaction!(transaction.id, [
               :club,
               :contact,
               :contract,
               entries: [:account]
             ]).contact.id == transaction.contact_id

      assert Accounting.get_transaction!(transaction.id, [
               :club,
               :contact,
               :contract,
               entries: [:account]
             ]).club.id == transaction.club_id
    end

    test "create_transaction/1 with valid data creates a transaction" do
      contract = contract_fixture()
      club = club_fixture()
      contact = contact_fixture()

      valid_attrs = %{
        contract_id: contract.id,
        contact_id: contact.id,
        club_id: club.id,
        amount: "42 €",
        creation_date: ~D[2023-06-04],
        name: "some name",
        receipt_number: "INV-123",
        type: "Einnahme"
      }

      assert {:ok, %Transaction{} = transaction} = Accounting.create_transaction(valid_attrs)
      assert transaction.amount == Money.new(:EUR, 42)
      assert transaction.creation_date == ~D[2023-06-04]
      assert transaction.name == "some name"
      assert transaction.type == "Einnahme"
      assert transaction.receipt_number == "INV-123"
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounting.create_transaction(@invalid_attrs)
    end

    test "create_transaction_from_ui/1 with valid data creates a transaction" do
      club = club_fixture()
      contact = contact_fixture()

      valid_attrs = %{
        contact_id: contact.id,
        club_id: club.id,
        amount: "42 €",
        creation_date: ~D[2025-11-30],
        name: "some name",
        receipt_number: "INV-123",
        type: "Einnahme",
        payment_date: ~D[2025-11-30]
      }

      assert {:ok, %Transaction{} = transaction} =
               Accounting.create_transaction_from_ui(valid_attrs)

      assert transaction.amount == Money.new(:EUR, 42)
      assert transaction.creation_date == ~D[2025-11-30]
      assert transaction.name == "some name"
      assert transaction.type == "Einnahme"
      assert transaction.receipt_number == "INV-123"
      assert transaction.payment_date == ~D[2025-11-30]
    end

    test "create_transaction_from_ui/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounting.create_transaction_from_ui(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()

      update_attrs = %{
        amount: "43 €",
        creation_date: ~D[2025-11-20],
        name: "some updated name",
        payment_date: ~D[2025-11-20],
        receipt_number: "INV-345",
        type: "Ausgabe"
      }

      assert {:ok, %Transaction{} = transaction} =
               Accounting.update_transaction(transaction, update_attrs)

      assert transaction.amount == Money.new(:EUR, 43)
      assert transaction.creation_date == ~D[2025-11-20]
      assert transaction.name == "some updated name"
      assert transaction.payment_date == ~D[2025-11-20]
      assert transaction.receipt_number == "INV-345"
      assert transaction.type == "Ausgabe"
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounting.update_transaction(transaction, @invalid_attrs)

      assert transaction == Accounting.get_transaction!(transaction.id)
    end

    test "update_transaction_and_entry/2 with valid data updates the transaction and the associated entry" do
      transaction = transaction_fixture()
      account = account_fixture()

      update_attrs = %{
        "amount" => "43 €",
        "creation_date" => ~D[2025-11-20],
        "name" => "some updated name",
        "payment_date" => ~D[2025-11-20],
        "receipt_number" => "INV-345",
        "type" => "Ausgabe",
        "account_id" => account.id
      }

      assert {:ok, %Transaction{} = transaction} =
               Accounting.update_transaction_and_entry(transaction, update_attrs)

      entry = Accounting.get_financial_account_entry(transaction.id)

      assert transaction.amount == Money.new(:EUR, 43)
      assert transaction.creation_date == ~D[2025-11-20]
      assert transaction.name == "some updated name"
      assert transaction.payment_date == ~D[2025-11-20]
      assert transaction.receipt_number == "INV-345"
      assert transaction.type == "Ausgabe"
      assert entry.account_id == account.id
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

  describe "accounts" do
    alias Sportyweb.Accounting.Account

    import Sportyweb.AccountingFixtures
    import Sportyweb.OrganizationFixtures

    @invalid_attrs %{name: nil, account_number: nil, club_id: nil, class: ""}

    test "list_accounts/1 returns all accounts of a given club" do
      account = account_fixture()
      [listed_account] = Accounting.list_accounts(account.club_id)
      assert [listed_account.id] == [account.id]
    end

    test "list_accounts/2 returns all accounts of a given club and a given list of account numbers" do
      club = club_fixture()

      valid_attrs = %{
        club_id: club.id,
        class: "Einnahmen",
        account_number: "45678",
        name: "some name"
      }

      assert {:ok, %Account{} = account} = Accounting.create_account(valid_attrs)
      options = ["4%", "70%", "71%", "74%", "770%", "771%", "773%", "774%", "775%", "78%"]
      assert Accounting.list_accounts(options, account.club_id) == [account]
    end

    test "list_financial_accounts/1 returns all financial accounts of a given club" do
      account = account_fixture()
      assert Accounting.list_financial_accounts(account.club_id) == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounting.get_account!(account.id) == account
    end

    test "get_account!/2 returns the account with given id and contains a preloaded club" do
      account = account_fixture()

      assert %Account{} = Accounting.get_account!(account.id, [:club])
      assert Accounting.get_account!(account.id, [:club]).club.id == account.club_id
    end

    test "get_account_and_balance!/2 returns the account with given id and contains a preloaded club" do
      account = account_fixture()

      assert %Account{} = Accounting.get_account_and_balance!(account.id, [:club])
      account_result = Accounting.get_account_and_balance!(account.id, [:club]).balance
      assert account_result == Money.new(:EUR, 0)
      assert Accounting.get_account!(account.id, [:club]).club.id == account.club_id
    end

    test "get_financial_account/2 returns the financial account's name with given transaction id and contains preloaded associations" do
      account = account_fixture()
      entry = entry_fixture()

      assert Accounting.get_financial_account(entry.transaction_id, [:entries]).name ==
               account.name
    end

    test "create_account/1 with valid data creates a account" do
      club = club_fixture()

      valid_attrs = %{
        name: "some name",
        class: "Einnahmen",
        account_number: "45678",
        club_id: club.id
      }

      assert {:ok, %Account{} = account} = Accounting.create_account(valid_attrs)
      assert account.name == "some name"
      assert account.class == "Einnahmen"
      assert account.account_number == "45678"
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounting.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()

      update_attrs = %{
        name: "some updated name",
        class: "Eigen-/Fremdkapital",
        account_number: "23456",
        archive_date: ~D[2025-11-18]
      }

      assert {:ok, %Account{} = account} = Accounting.update_account(account, update_attrs)
      assert account.name == "some updated name"
      assert account.class == "Eigen-/Fremdkapital"
      assert account.account_number == "23456"
      assert account.archive_date == ~D[2025-11-18]
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounting.update_account(account, @invalid_attrs)
      assert account == Accounting.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Accounting.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounting.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounting.change_account(account)
    end

    test "determine_account_class/1 returns the class of an account with given account number" do
      assert Accounting.determine_account_class("12345") == "Umlaufvermögen"
    end
  end

  describe "entries" do
    alias Sportyweb.Accounting.Entry

    import Sportyweb.AccountingFixtures
    import Sportyweb.OrganizationFixtures

    @invalid_attrs %{type: "", amount: nil, sphere: nil, account_id: nil, transaction_id: nil}

    test "list_entries/2 returns all entries for a given transaction and contains preloaded associations" do
      entry = entry_fixture()

      entries = Accounting.list_entries(entry.transaction_id, [:account])
      assert List.first(entries).transaction_id == entry.transaction_id
    end

    test "get_entry!/1 returns the entry with given id" do
      entry = entry_fixture()
      assert Accounting.get_entry!(entry.id) == entry
    end

    test "get_entry!/2 returns the entry with given id and contains preloaded associations" do
      entry = entry_fixture()

      assert %Entry{} = Accounting.get_entry!(entry.id, [:account])
      assert Accounting.get_entry!(entry.id, [:account]).account_id == entry.account_id
    end

    test "get_financial_account_entry/1 returns the transactions entry to a financial account" do
      transaction = transaction_fixture()
      [entry] = Accounting.list_entries(transaction.id, [])
      assert Accounting.get_financial_account_entry(transaction.id) == entry
    end

    test "create_entry/1 with valid data creates a entry" do
      transaction = transaction_fixture()
      account = account_fixture()

      valid_attrs = %{
        transaction_id: transaction.id,
        account_id: account.id,
        type: "S",
        amount: Money.new(:EUR, 42),
        sphere: 4
      }

      assert {:ok, %Entry{} = entry} = Accounting.create_entry(valid_attrs)
      assert entry.type == "S"
      assert entry.amount == Money.new(:EUR, 42)
      assert entry.sphere == 4
    end

    test "create_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounting.create_entry(@invalid_attrs)
    end

    test "create_financial_account_entry/1 with valid data creates a entry for a financial account" do
      transaction = transaction_fixture()
      account = account_fixture()

      valid_attrs = %{
        transaction_id: transaction.id,
        account_id: account.id,
        type: "S",
        amount: Money.new(:EUR, 42),
        sphere: 4
      }

      assert {:ok, %Entry{} = entry} = Accounting.create_financial_account_entry(valid_attrs)
      assert entry.type == "S"
      assert entry.amount == Money.new(:EUR, 42)
      assert entry.sphere == 4
    end

    test "create_financial_account_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Accounting.create_financial_account_entry(@invalid_attrs)
    end

    test "update_entry/2 with valid data updates the entry" do
      entry = entry_fixture()

      update_attrs = %{
        type: "H",
        amount: Money.new(:EUR, 41),
        sphere: 1
      }

      assert {:ok, %Entry{} = entry} = Accounting.update_entry(entry, update_attrs)
      assert entry.type == "H"
      assert entry.amount == Money.new(:EUR, 41)
      assert entry.sphere == 1
    end

    test "update_entry/2 with higher amount than the transaction's amount returns error changeset" do
      entry = entry_fixture()

      update_attrs = %{
        type: "H",
        amount: Money.new(:EUR, 50),
        sphere: 1
      }

      assert {:error, %Ecto.Changeset{}} = Accounting.update_entry(entry, update_attrs)
      assert entry == Accounting.get_entry!(entry.id)
    end

    test "update_entry/2 with invalid data returns error changeset" do
      entry = entry_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounting.update_entry(entry, @invalid_attrs)
      assert entry == Accounting.get_entry!(entry.id)
    end

    test "delete_entry/1 deletes the entry" do
      entry = entry_fixture()
      assert {:ok, %Entry{}} = Accounting.delete_entry(entry)
      assert_raise Ecto.NoResultsError, fn -> Accounting.get_entry!(entry.id) end
    end

    test "change_entry/1 returns a entry changeset" do
      entry = entry_fixture()
      assert %Ecto.Changeset{} = Accounting.change_entry(entry)
    end
  end
end
