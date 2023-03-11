defmodule Sportyweb.CalendarFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Calendar` context.
  """

  import Sportyweb.OrganizationFixtures

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    club = club_fixture()

    {:ok, event} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        name: "some name",
        reference_number: "some reference_number",
        status: "public",
        description: "some description",
        minimum_participants: 0,
        maximum_participants: 12,
        minimum_age_in_years: 0,
        maximum_age_in_years: 100,
        location_type: "no_info",
        location_description: "some location_description"
      })
      |> Sportyweb.Calendar.create_event()

    event
  end
end
