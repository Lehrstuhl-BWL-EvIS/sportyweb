defmodule Sportyweb.PersonalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Personal` context.
  """

  import Sportyweb.OrganizationFixtures

  @doc """
  Generate a contact.
  """
  def contact_fixture(attrs \\ %{}) do
    club = club_fixture()

    {:ok, contact} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        type: "person",
        organization_name: "some organization_name",
        organization_type: "club",
        person_last_name: "some person_last_name",
        person_first_name_1: "some person_first_name_1",
        person_first_name_2: "some person_first_name_2",
        person_gender: "other",
        person_birthday: ~D[2023-02-15]
      })
      |> Sportyweb.Personal.create_contact()

    contact
  end
end
