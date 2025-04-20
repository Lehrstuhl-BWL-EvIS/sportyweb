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

  @doc """
  Generate a membership.
  """
  def membership_fixture(attrs \\ %{}) do
    contract = contract_fixture()

    {:ok, membership} =
      attrs
      |> Enum.into(%{
        club_id: contract.club_id,
        contact_id: contract.contact_id,
        department_id: contract.department_id,
        group_id: contract.group_id,
        contract_id: contract.id
      })
      |> Sportyweb.Legal.create_membership()

    membership
  end
end
