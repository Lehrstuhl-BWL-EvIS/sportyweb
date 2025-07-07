defmodule Sportyweb.PersonalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Personal` context.
  """

  import Sportyweb.OrganizationFixtures
  import Sportyweb.PolymorphicFixtures
  alias Sportyweb.Organization.Club

  @doc """
  Generate a contact.
  """
  def contact_fixture(attrs \\ %{}, %Club{} = club \\ club_fixture()) do
    {:ok, contact} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        type: "person",
        organization_name: "some organization_name",
        organization_type: "club",
        person_last_name: "some person_last_name",
        person_first_name: "some person_first_name",
        person_gender: "other",
        person_birthday: ~D[2000-02-15],
        address: postal_address_attrs(),
        email: "someone@example.com",
        phone: "012345 678910",
        financial_data: financial_data_attrs(),
        note: "some content"
      })
      |> Sportyweb.Personal.create_contact("test")

    contact
  end

  @doc """
  Generate a contact_group.
  """
  def contact_group_fixture(attrs \\ %{}) do
    club = club_fixture()

    {:ok, contact_group} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        name: "group name"
      })
      |> Sportyweb.Personal.create_contact_group("test")

    contact_group
  end
end
