defmodule Sportyweb.AssetFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Asset` context.
  """

  @doc """
  Generate a venue.
  """
  def venue_fixture(attrs \\ %{}) do
    {:ok, venue} =
      attrs
      |> Enum.into(%{
        description: "some description",
        is_main: true,
        name: "some name",
        reference_number: "some reference_number"
      })
      |> Sportyweb.Asset.create_venue()

    venue
  end
end
