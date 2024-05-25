defmodule Sportyweb.CalendarFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Calendar` context.
  """

  import Sportyweb.OrganizationFixtures
  import Sportyweb.PolymorphicFixtures

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
        minimum_participants: 5,
        maximum_participants: 12,
        minimum_age_in_years: nil,
        maximum_age_in_years: nil,
        venue_type: "free_form",
        venue_description: "some venue_description",
        emails: [email_attrs()],
        phones: [phone_attrs()],
        notes: [note_attrs()]
      })
      |> Sportyweb.Calendar.create_event()

    event
  end
end
