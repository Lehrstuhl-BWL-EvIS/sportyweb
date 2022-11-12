defmodule Sportyweb.MembershipFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Membership` context.
  """

  @doc """
  Generate a unique household identifier.
  """
  def unique_household_identifier, do: "some identifier#{System.unique_integer([:positive])}"

  @doc """
  Generate a household.
  """
  def household_fixture(attrs \\ %{}) do
    {:ok, household} =
      attrs
      |> Enum.into(%{
        identifier: unique_household_identifier()
      })
      |> Sportyweb.Membership.create_household()

    household
  end
end
