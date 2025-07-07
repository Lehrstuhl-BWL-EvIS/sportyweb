defmodule Sportyweb.PersonalTest do
  use Sportyweb.DataCase, async: true

  alias Sportyweb.Personal
  alias Sportyweb.History

  describe "contacts" do
    alias Sportyweb.Personal.Contact

    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PolymorphicFixtures

    @invalid_attrs %{
      club_id: "a3428f2e-42c8-428b-80ae-ab6e4dc4e52d",
      organization_name: nil,
      organization_type: nil,
      person_birthday: nil,
      person_first_name: nil,
      person_gender: nil,
      person_last_name: nil,
      type: nil
    }

    test "list_contacts/1 returns all contacts of a given club" do
      contact = contact_fixture()
      assert List.first(Personal.list_contacts(contact.club_id)).id == contact.id
    end

    test "list_contacts/3 without order or filter returns all contacts of a given club" do
      contact = contact_fixture()

      assert Personal.list_contacts(contact.club_id, nil, nil) == [contact]
    end

    test "list_contacts/3 without filter returns all contacts in correct order" do
      club = club_fixture()
      youngest_contact = contact_fixture(%{person_birthday: ~D[2003-02-15], club_id: club.id})
      middle_contact = contact_fixture(%{person_birthday: ~D[2001-02-15], club_id: club.id})
      oldest_contact = contact_fixture(%{person_birthday: ~D[2000-02-15], club_id: club.id})

      contacts =
        Personal.list_contacts(club.id, [asc: :person_birthday], nil)

      assert contacts == [oldest_contact, middle_contact, youngest_contact]

      contacts =
        Personal.list_contacts(club.id, [desc: :person_birthday], nil)

      assert contacts == [youngest_contact, middle_contact, oldest_contact]
    end

    test "list_contacts/4 with order and filter returns wanted contacts in correct order" do
      club = club_fixture()

      contact1 =
        contact_fixture(%{
          person_birthday: ~D[2003-02-15],
          club_id: club.id,
          person_last_name: "my name 1"
        })

      contact2 =
        contact_fixture(%{
          person_birthday: ~D[2000-02-15],
          club_id: club.id,
          person_last_name: "CAPITALNAME"
        })

      contact_fixture(%{
        person_birthday: ~D[2001-02-15],
        club_id: club.id,
        person_last_name: "someting else"
      })

      contacts =
        Personal.list_contacts(club.id, [asc: :person_birthday], person_last_name: "%name%")

      assert contacts == [contact2, contact1]
    end

    test "list_contacts/3 works with multiple filters" do
      club = club_fixture()

      contact1 =
        contact_fixture(%{
          person_birthday: ~D[2003-02-15],
          club_id: club.id,
          person_first_name: "Alex",
          person_last_name: "my name 1"
        })

      contact2 =
        contact_fixture(%{
          person_birthday: ~D[2000-02-15],
          club_id: club.id,
          person_first_name: "Alex",
          person_last_name: "CAPITALNAME"
        })

      contact_fixture(%{
        person_birthday: ~D[2001-02-15],
        club_id: club.id,
        person_first_name: "Alex",
        person_last_name: "someting else"
      })

      contact_fixture(%{
        person_birthday: ~D[2001-02-15],
        club_id: club.id,
        person_first_name: "John",
        person_last_name: "last name matches"
      })

      contacts =
        Personal.list_contacts(
          club.id,
          [asc: :person_birthday],
          person_last_name: "%name%",
          person_first_name: "Alex"
        )

      assert contacts == [contact2, contact1]
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Personal.get_contact!(contact.id).id == contact.id
    end

    test "get_contact!/1 returns the contact with given id and contains preloaded associations" do
      contact = contact_fixture()

      assert Personal.get_contact!(contact.id) == contact
    end

    test "create_contact/1 with valid data creates a contact and writes to history" do
      club = club_fixture()

      valid_attrs = %{
        club_id: club.id,
        organization_name: "some organization_name",
        organization_type: "club",
        person_birthday: ~D[2023-02-15],
        person_first_name: "some person_first_name",
        person_gender: "female",
        person_last_name: "some person_last_name",
        type: "person",
        email: "someone@example.com",
        financial_data: financial_data_attrs(),
        notes: "some content",
        phones: "012345 678910",
        postal_addresses: postal_address_attrs()
      }

      assert {:ok, %Contact{} = contact} = Personal.create_contact(valid_attrs, "test")
      assert contact.organization_name == "some organization_name"
      assert contact.organization_type == "club"
      assert contact.person_birthday == ~D[2023-02-15]
      assert contact.person_first_name == "some person_first_name"
      assert contact.person_gender == "female"
      assert contact.person_last_name == "some person_last_name"
      assert contact.type == "person"

      changes = History.list_changes("contact", contact.id)
      assert Enum.count(changes) == 1

      assert Enum.any?(changes, fn c ->
               c.attribute == "-creation-" and c.changed_by == "test" and
                 c.new_value == "-"
             end)
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Personal.create_contact(@invalid_attrs, "test")

      assert Enum.empty?(History.list_all_changes_of_club(@invalid_attrs.club_id))
    end

    test "update_contact/2 with valid data updates the contact and writes to history" do
      contact = contact_fixture()

      update_attrs = %{
        organization_name: "some updated organization_name",
        organization_type: "corporation",
        person_birthday: ~D[2023-02-16],
        person_first_name: "some updated person_first_name",
        person_gender: "male",
        person_last_name: "some updated person_last_name",
        type: "organization"
      }

      assert {:ok, %Contact{} = contact} = Personal.update_contact(contact, update_attrs, "test")
      assert contact.organization_name == "some updated organization_name"
      assert contact.organization_type == "corporation"
      assert contact.person_birthday == ~D[2023-02-16]
      assert contact.person_first_name == "some updated person_first_name"
      assert contact.person_gender == "male"
      assert contact.person_last_name == "some updated person_last_name"
      assert contact.type == "organization"

      changes = History.list_changes("contact", contact.id)
      assert Enum.count(changes) == 9

      assert Enum.any?(changes, fn c ->
               c.attribute == "person_gender" and c.changed_by == "test" and c.new_value == "male"
             end)

      assert Enum.any?(changes, fn c ->
               c.attribute == "type" and c.changed_by == "test" and c.new_value == "organization"
             end)
    end

    test "update_contact/2 with invalid data returns error changeset" do
      contact = contact_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Personal.update_contact(contact, @invalid_attrs, "test")

      assert contact == Personal.get_contact!(contact.id)

      changes = History.list_changes("contact", contact.id)
      assert Enum.count(changes) == 1

      assert Enum.any?(changes, fn c ->
               c.attribute == "-creation-" and c.changed_by == "test" and c.new_value == "-"
             end)
    end

    test "delete_contact/1 deletes the contact and writes to history" do
      contact = contact_fixture()
      contact = Map.put(contact, :contact_group_contacts, [])
      assert {:ok, %Contact{} = contact} = Personal.delete_contact(contact, "test")
      assert_raise Ecto.NoResultsError, fn -> Personal.get_contact!(contact.id) end

      changes = History.list_changes("contact", contact.id)
      assert Enum.count(changes) == 2

      assert Enum.any?(changes, fn c ->
               c.attribute == "-deletion-" and c.changed_by == "test" and c.new_value == "-"
             end)
    end

    test "change_contact/1 returns a contact changeset" do
      contact = contact_fixture()
      assert %Ecto.Changeset{} = Personal.change_contact(contact)
    end
  end

  describe "contact_groups" do
    alias Sportyweb.Personal.ContactGroup

    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures

    @invalid_attrs %{club_id: "a3428f2e-42c8-428b-80ae-ab6e4dc4e52d", name: nil}

    test "get_contact_group!/1 returns the contact_group with given id" do
      contact_group = contact_group_fixture()
      assert Personal.get_contact_group!(contact_group.id) == contact_group
    end

    test "create_contact_group/1 with valid data creates a contact_group and writes to history" do
      club = club_fixture()
      contact = contact_fixture()

      valid_attrs = %{
        club_id: club.id,
        contact_id: contact.id,
        name: "test group name"
      }

      assert {:ok, %ContactGroup{} = contact_group} =
               Personal.create_contact_group(valid_attrs, "test")

      changes = History.list_changes("contact_group", contact_group.id)
      assert Enum.count(changes) == 1

      assert Enum.any?(changes, fn c ->
               c.attribute == "-creation-" and c.changed_by == "test" and
                 c.new_value == "-"
             end)
    end

    test "create_contact_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Personal.create_contact_group(@invalid_attrs, "test")

      assert Enum.empty?(History.list_all_changes_of_club(@invalid_attrs.club_id))
    end

    test "update_contact_group/2 with valid data updates the contact_group and writes to history" do
      contact_group = contact_group_fixture()
      update_attrs = %{name: "new name"}

      assert {:ok, %ContactGroup{}} =
               Personal.update_contact_group(contact_group, update_attrs, "test")

      changes = History.list_changes("contact_group", contact_group.id)
      assert Enum.count(changes) == 2

      assert Enum.any?(changes, fn c ->
               c.attribute == "name" and c.changed_by == "test" and c.new_value == "new name"
             end)
    end

    test "update_contact_group/2 with invalid data returns error changeset" do
      contact_group = contact_group_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Personal.update_contact_group(contact_group, @invalid_attrs, "test")

      assert contact_group == Personal.get_contact_group!(contact_group.id)

      changes = History.list_changes("contact_group", contact_group.id)
      assert Enum.count(changes) == 1

      assert Enum.any?(changes, fn c ->
               c.attribute == "-creation-" and c.changed_by == "test" and c.new_value == "-"
             end)
    end

    test "delete_contact_group/1 deletes the contact_group and writes to history" do
      contact_group = contact_group_fixture()
      assert {:ok, %ContactGroup{}} = Personal.delete_contact_group(contact_group, "test")
      assert_raise Ecto.NoResultsError, fn -> Personal.get_contact_group!(contact_group.id) end

      changes = History.list_changes("contact_group", contact_group.id)
      assert Enum.count(changes) == 2

      assert Enum.any?(changes, fn c ->
               c.attribute == "-deletion-" and c.changed_by == "test" and c.new_value == "-"
             end)
    end

    test "change_contact_group/1 returns a contact_group changeset" do
      contact_group = contact_group_fixture()
      assert %Ecto.Changeset{} = Personal.change_contact_group(contact_group)
    end
  end
end
