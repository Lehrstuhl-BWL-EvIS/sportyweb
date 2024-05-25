defmodule Sportyweb.AssetFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Asset` context.
  """

  import Sportyweb.OrganizationFixtures
  import Sportyweb.PolymorphicFixtures

  @doc """
  Generate a location.
  """
  def location_fixture(attrs \\ %{}) do
    club = club_fixture()

    {:ok, location} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        name: "some name",
        reference_number: "some reference_number",
        description: "some description",
        postal_addresses: [postal_address_attrs()],
        emails: [email_attrs()],
        phones: [phone_attrs()],
        notes: [note_attrs()]
      })
      |> Sportyweb.Asset.create_location()

    location
  end

  @doc """
  Generate a equipment.
  """
  def equipment_fixture(attrs \\ %{}) do
    location = location_fixture()

    {:ok, equipment} =
      attrs
      |> Enum.into(%{
        location_id: location.id,
        name: "some name",
        reference_number: "some reference_number",
        serial_number: "some serial_number",
        description: "some description",
        purchase_date: ~D[2022-11-05],
        commission_date: ~D[2022-11-10],
        decommission_date: ~D[2022-11-15],
        emails: [email_attrs()],
        phones: [phone_attrs()],
        notes: [note_attrs()]
      })
      |> Sportyweb.Asset.create_equipment()

    equipment
  end
end
