defmodule Sportyweb.PersonalTest do
  use Sportyweb.DataCase

  alias Sportyweb.Personal

  describe "contacts" do
    alias Sportyweb.Personal.Contact

    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures

    @invalid_attrs %{organization_name: nil, organization_type: nil, person_birthday: nil, person_first_name_1: nil, person_first_name_2: nil, person_gender: nil, person_last_name: nil, type: nil}

    test "list_contacts/1 returns all contacts of a given club" do
      contact = contact_fixture()
      assert Personal.list_contacts(contact.club_id) == [contact]
    end

    test "list_contacts/2 returns all contacts of a given club with preloaded associations" do
      # TODO
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Personal.get_contact!(contact.id) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      club = club_fixture()
      valid_attrs = %{club_id: club.id, organization_name: "some organization_name", organization_type: "club", person_birthday: ~D[2023-02-15], person_first_name_1: "some person_first_name_1", person_first_name_2: "some person_first_name_2", person_gender: "female", person_last_name: "some person_last_name", type: "person"}

      assert {:ok, %Contact{} = contact} = Personal.create_contact(valid_attrs)
      assert contact.organization_name == "some organization_name"
      assert contact.organization_type == "club"
      assert contact.person_birthday == ~D[2023-02-15]
      assert contact.person_first_name_1 == "some person_first_name_1"
      assert contact.person_first_name_2 == "some person_first_name_2"
      assert contact.person_gender == "female"
      assert contact.person_last_name == "some person_last_name"
      assert contact.type == "person"
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Personal.create_contact(@invalid_attrs)
    end

    test "update_contact/2 with valid data updates the contact" do
      contact = contact_fixture()
      update_attrs = %{organization_name: "some updated organization_name", organization_type: "corporation", person_birthday: ~D[2023-02-16], person_first_name_1: "some updated person_first_name_1", person_first_name_2: "some updated person_first_name_2", person_gender: "male", person_last_name: "some updated person_last_name", type: "organization"}

      assert {:ok, %Contact{} = contact} = Personal.update_contact(contact, update_attrs)
      assert contact.organization_name == "some updated organization_name"
      assert contact.organization_type == "corporation"
      assert contact.person_birthday == ~D[2023-02-16]
      assert contact.person_first_name_1 == "some updated person_first_name_1"
      assert contact.person_first_name_2 == "some updated person_first_name_2"
      assert contact.person_gender == "male"
      assert contact.person_last_name == "some updated person_last_name"
      assert contact.type == "organization"
    end

    test "update_contact/2 with invalid data returns error changeset" do
      contact = contact_fixture()
      assert {:error, %Ecto.Changeset{}} = Personal.update_contact(contact, @invalid_attrs)
      assert contact == Personal.get_contact!(contact.id)
    end

    test "delete_contact/1 deletes the contact" do
      contact = contact_fixture()
      assert {:ok, %Contact{}} = Personal.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> Personal.get_contact!(contact.id) end
    end

    test "change_contact/1 returns a contact changeset" do
      contact = contact_fixture()
      assert %Ecto.Changeset{} = Personal.change_contact(contact)
    end
  end
end