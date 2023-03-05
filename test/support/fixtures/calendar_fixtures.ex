defmodule Sportyweb.CalendarFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Calendar` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        description: "some description",
        location_description: "some location_description",
        location_type: "some location_type",
        maximum_age_in_years: 42,
        maximum_participants: 42,
        minimum_age_in_years: 42,
        minimum_participants: 42,
        name: "some name",
        reference_number: "some reference_number",
        status: "some status"
      })
      |> Sportyweb.Calendar.create_event()

    event
  end
end
