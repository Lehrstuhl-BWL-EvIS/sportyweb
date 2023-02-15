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
    {:ok, equipment} =
      attrs
      |> Enum.into(%{
        commission_at: ~D[2023-02-14],
        decommission_at: ~D[2023-02-14],
        description: "some description",
        name: "some name",
        purchased_at: ~D[2023-02-14],
        reference_number: "some reference_number",
        serial_number: "some serial_number"
      })
      |> Sportyweb.Asset.create_equipment()

    equipment
  end
end
