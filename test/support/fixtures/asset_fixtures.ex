defmodule Sportyweb.AssetFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Asset` context.
  """

  import Sportyweb.OrganizationFixtures

  @doc """
  Generate a venue.
  """
  def venue_fixture(attrs \\ %{}) do
    club = club_fixture()

    {:ok, venue} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        name: "some name",
        reference_number: "some reference_number",
        description: "some description",
        is_main: false
      })
      |> Sportyweb.Asset.create_venue()

    venue
  end
end
