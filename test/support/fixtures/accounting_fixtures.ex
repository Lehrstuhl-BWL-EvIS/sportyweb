defmodule Sportyweb.AccountingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Accounting` context.
  """

  import Sportyweb.LegalFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.PersonalFixtures

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    contract = contract_fixture()
    club = club_fixture()
    contact = contact_fixture()
    account = account_fixture()

    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        "contract_id" => contract.id,
        "contact_id" => contact.id,
        "club_id" => club.id,
        "name" => "some name",
        "amount" => Money.new(:EUR, 42),
        "creation_date" => ~D[2025-11-19],
        "payment_date" => ~D[2025-11-19],
        "receipt_number" => "INV-123",
        "type" => "Einnahme",
        "account_id" => account.id
      })
      |> Sportyweb.Accounting.create_transaction_and_entry()

    transaction
  end

  @doc """
  Generate a account.
  """
  def account_fixture(attrs \\ %{}) do
    club = club_fixture()

    {:ok, account} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        name: "some name",
        account_number: "16000",
        class: "Umlaufvermögen"
      })
      |> Sportyweb.Accounting.create_account()

    account
  end

  @doc """
  Generate a account.
  """
  def account_fixture1(attrs \\ %{}) do
    club = club_fixture()

    {:ok, account} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        name: "some name",
        account_number: "46789",
        class: "Einnahmen"
      })
      |> Sportyweb.Accounting.create_account()

    account
  end

  @doc """
  Generate a entry.
  """
  def entry_fixture(attrs \\ %{}) do
    transaction = transaction_fixture()
    account = account_fixture1()

    {:ok, entry} =
      attrs
      |> Enum.into(%{
        transaction_id: transaction.id,
        account_id: account.id,
        type: "S",
        amount: Money.new(:EUR, 42),
        sphere: 4
      })
      |> Sportyweb.Accounting.create_entry()

    entry
  end
end
