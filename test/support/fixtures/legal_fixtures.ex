defmodule Sportyweb.LegalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Legal` context.
  """

  @doc """
  Generate a fee.
  """
  def fee_fixture(attrs \\ %{}) do
    {:ok, fee} =
      attrs
      |> Enum.into(%{
        admission_fee_in_eur_cent: 42,
        base_fee_in_eur_cent: 42,
        commission_at: ~D[2023-02-24],
        decommission_at: ~D[2023-02-24],
        description: "some description",
        is_group_only: true,
        is_recurring: true,
        maximum_age_in_years: 42,
        minimum_age_in_years: 42,
        name: "some name",
        reference_number: "some reference_number",
        type: "some type"
      })
      |> Sportyweb.Legal.create_fee()

    fee
  end
end
