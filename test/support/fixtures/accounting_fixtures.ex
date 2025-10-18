defmodule Sportyweb.AccountingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Accounting` context.
  """

  import Sportyweb.LegalFixtures

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    contract = contract_fixture()

    {:ok, transaction} =
      attrs
      |> Enum.into(%{
        contract_id: contract.id,
        name: "some name",
        amount: Money.new(:EUR, 42),
        creation_date: ~D[2023-06-01],
        payment_date: ~D[2023-06-15]
      })
      |> Sportyweb.Accounting.create_transaction()

    transaction
  end

  @doc """
  Generate a account.
  """
  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> Enum.into(%{
        name: "some name",
        number: 42,
        type: "some type"
      })
      |> Sportyweb.Accounting.create_account()

    account
  end
end
