defmodule Sportyweb.LegalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Legal` context.
  """

  import Sportyweb.OrganizationFixtures

  @doc """
  Generate a fee.
  """
  def fee_fixture(attrs \\ %{}) do
    club = club_fixture()

    {:ok, fee} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        is_general: true,
        type: "club",
        name: "some name",
        reference_number: "some reference_number",
        description: "some description",
        base_fee_in_eur_cent: 42,
        admission_fee_in_eur_cent: 42,
        is_group_only: true,
        is_recurring: true,
        minimum_age_in_years: 42,
        maximum_age_in_years: 42,
        commission_at: ~D[2023-02-24],
        decommission_at: ~D[2023-02-24],
      })
      |> Sportyweb.Legal.create_fee()

    fee
  end
end
