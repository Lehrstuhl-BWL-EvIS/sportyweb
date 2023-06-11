defmodule Sportyweb.LegalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Legal` context.
  """

  import Sportyweb.FinanceFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.PersonalFixtures

  @doc """
  Generate a contract.
  """
  def contract_fixture(attrs \\ %{}) do
    club = club_fixture()
    contact = contact_fixture()
    fee = fee_fixture()

    {:ok, contract} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        contact_id: contact.id,
        fee_id: fee.id,
        signing_date: ~D[2023-06-01],
        start_date: ~D[2023-07-01],
        first_billing_date: nil,
        termination_date: nil,
        archive_date: nil,
        clubs: [club]
      })
      |> Sportyweb.Legal.create_contract()

    contract
  end
end
