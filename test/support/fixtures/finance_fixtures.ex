defmodule Sportyweb.FinanceFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Finance` context.
  """

  import Sportyweb.OrganizationFixtures
  import Sportyweb.PolymorphicFixtures

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
        amount: Money.new(:EUR, 50),
        amount_one_time: Money.new(:EUR, 10),
        is_for_contact_group_contacts_only: true,
        minimum_age_in_years: 18,
        maximum_age_in_years: 50,
        internal_events: [internal_event_attrs()],
        notes: [note_attrs()]
      })
      |> Sportyweb.Finance.create_fee()

    fee
  end

  @doc """
  Generate a subsidy.
  """
  def subsidy_fixture(attrs \\ %{}) do
    club = club_fixture()

    {:ok, subsidy} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        name: "some name",
        reference_number: "some reference_number",
        description: "some description",
        amount: Money.new(:EUR, 30),
        internal_events: [internal_event_attrs()],
        notes: [note_attrs()]
      })
      |> Sportyweb.Finance.create_subsidy()

    subsidy
  end
end
