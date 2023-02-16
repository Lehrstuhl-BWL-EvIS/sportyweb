defmodule Sportyweb.PersonalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Personal` context.
  """

  @doc """
  Generate a contact.
  """
  def contact_fixture(attrs \\ %{}) do
    {:ok, contact} =
      attrs
      |> Enum.into(%{
        organization_name: "some organization_name",
        person_birthday: ~D[2023-02-15],
        person_first_name_1: "some person_first_name_1",
        person_first_name_2: "some person_first_name_2",
        person_gender: "some person_gender",
        person_last_name: "some person_last_name",
        type: "some type"
      })
      |> Sportyweb.Personal.create_contact()

    contact
  end
end
