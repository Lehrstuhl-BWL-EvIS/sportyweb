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

  @doc """
  Generate a equipment.
  """
  def equipment_fixture(attrs \\ %{}) do
    venue = venue_fixture()

    {:ok, equipment} =
      attrs
      |> Enum.into(%{
        venue_id: venue.id,
        name: "some name",
        reference_number: "some reference_number",
        serial_number: "some serial_number",
        description: "some description",
        purchased_at: ~D[2022-11-05],
        commission_at: ~D[2022-11-10],
        decommission_at: ~D[2022-11-15],
      })
      |> Sportyweb.Asset.create_equipment()

    equipment
  end
end
