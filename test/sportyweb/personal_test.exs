defmodule Sportyweb.PersonalTest do
  use Sportyweb.DataCase, async: true

  alias Sportyweb.Personal

  describe "contact" do
    alias Sportyweb.Personal.Contact

    import Sportyweb.PersonalFixtures

    test "age_in_years/2 returns correct age" do
      contact = contact_fixture(%{person_birthday: ~D[2000-03-15]})

      assert Contact.age_in_years(contact, ~D[2025-03-14]) == 24
      assert Contact.age_in_years(contact, ~D[2025-03-15]) == 25
    end
  end

  describe "contacts" do
    alias Sportyweb.Personal.Contact

    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PolymorphicFixtures

    @invalid_attrs %{
      organization_name: nil,
      organization_type: nil,
      person_birthday: nil,
      person_first_name_1: nil,
      person_first_name_2: nil,
      person_gender: nil,
      person_last_name: nil,
      type: nil
    }

    test "list_contacts/1 returns all contacts of a given club" do
      contact = contact_fixture()
      assert List.first(Personal.list_contacts(contact.club_id)).id == contact.id
    end

    test "list_contacts/4 without order or filter returns all contacts of a given club with preloaded associations" do
      contact = contact_fixture()

      assert Personal.list_contacts(contact.club_id, nil, nil, [
               :emails,
               :financial_data,
               :notes,
               :phones,
               :postal_addresses
             ]) == [contact]
    end

    test "list_contacts/4 without filter returns all contacts in correct order" do
      club = club_fixture()
      youngest_contact = contact_fixture(%{person_birthday: ~D[2003-02-15], club_id: club.id})
      middle_contact = contact_fixture(%{person_birthday: ~D[2001-02-15], club_id: club.id})
      oldest_contact = contact_fixture(%{person_birthday: ~D[2000-02-15], club_id: club.id})

      contacts = Personal.list_contacts(club.id, [asc: :person_birthday], nil, [:emails, :financial_data, :notes, :phones, :postal_addresses])
      assert contacts == [oldest_contact, middle_contact, youngest_contact]

      contacts = Personal.list_contacts(club.id, [desc: :person_birthday], nil, [:emails, :financial_data, :notes, :phones, :postal_addresses])
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
        Personal.list_contacts(club.id, [asc: :person_birthday], [person_last_name: "%name%"], [:emails, :financial_data, :notes, :phones, :postal_addresses])
      assert contacts == [contact2, contact1]
    end

    test "list_contacts/4 works with multiple filters" do
      club = club_fixture()

      contact1 =
        contact_fixture(%{
          person_birthday: ~D[2003-02-15],
          club_id: club.id,
          person_first_name_1: "Alex",
          person_last_name: "my name 1"
        })

      contact2 =
        contact_fixture(%{
          person_birthday: ~D[2000-02-15],
          club_id: club.id,
          person_first_name_1: "Alex",
          person_last_name: "CAPITALNAME"
        })

      contact_fixture(%{
        person_birthday: ~D[2001-02-15],
        club_id: club.id,
        person_first_name_1: "Alex",
        person_last_name: "someting else"
      })

      contact_fixture(%{
        person_birthday: ~D[2001-02-15],
        club_id: club.id,
        person_first_name_1: "John",
        person_last_name: "last name matches"
      })

      contacts =
        Personal.list_contacts(club.id, [asc: :person_birthday], [person_last_name: "%name%", person_first_name_1: "Alex"],
                                                                                   [:emails, :financial_data, :notes, :phones, :postal_addresses])
      assert contacts == [contact2, contact1]
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Personal.get_contact!(contact.id).id == contact.id
    end

    test "get_contact!/2 returns the contact with given id and contains preloaded associations" do
      contact = contact_fixture()

      assert Personal.get_contact!(contact.id, [
               :emails,
               :financial_data,
               :notes,
               :phones,
               :postal_addresses
             ]) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      club = club_fixture()

      valid_attrs = %{
        club_id: club.id,
        organization_name: "some organization_name",
        organization_type: "club",
        person_birthday: ~D[2023-02-15],
        person_first_name_1: "some person_first_name_1",
        person_first_name_2: "some person_first_name_2",
        person_gender: "female",
        person_last_name: "some person_last_name",
        type: "person",
        emails: [email_attrs()],
        financial_data: [financial_data_attrs()],
        notes: [note_attrs()],
        phones: [phone_attrs()],
        postal_addresses: [postal_address_attrs()]
      }

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

      update_attrs = %{
        organization_name: "some updated organization_name",
        organization_type: "corporation",
        person_birthday: ~D[2023-02-16],
        person_first_name_1: "some updated person_first_name_1",
        person_first_name_2: "some updated person_first_name_2",
        person_gender: "male",
        person_last_name: "some updated person_last_name",
        type: "organization"
      }

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

      assert contact ==
               Personal.get_contact!(contact.id, [
                 :emails,
                 :financial_data,
                 :phones,
                 :notes,
                 :postal_addresses
               ])
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

  describe "contact_groups" do
    alias Sportyweb.Personal.ContactGroup

    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures

    @invalid_attrs %{club_id: nil}

    test "list_contact_groups/0 returns all contact_groups" do
      contact_group = contact_group_fixture()
      assert Personal.list_contact_groups() == [contact_group]
    end

    test "get_contact_group!/1 returns the contact_group with given id" do
      contact_group = contact_group_fixture()
      assert Personal.get_contact_group!(contact_group.id) == contact_group
    end

    test "create_contact_group/1 with valid data creates a contact_group" do
      club = club_fixture()
      contact = contact_fixture()

      valid_attrs = %{
        club_id: club.id,
        contact_id: contact.id
      }

      assert {:ok, %ContactGroup{}} = Personal.create_contact_group(valid_attrs)
    end

    test "create_contact_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Personal.create_contact_group(@invalid_attrs)
    end

    test "update_contact_group/2 with valid data updates the contact_group" do
      contact_group = contact_group_fixture()
      update_attrs = %{}

      assert {:ok, %ContactGroup{}} = Personal.update_contact_group(contact_group, update_attrs)
    end

    test "update_contact_group/2 with invalid data returns error changeset" do
      contact_group = contact_group_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Personal.update_contact_group(contact_group, @invalid_attrs)

      assert contact_group == Personal.get_contact_group!(contact_group.id)
    end

    test "delete_contact_group/1 deletes the contact_group" do
      contact_group = contact_group_fixture()
      assert {:ok, %ContactGroup{}} = Personal.delete_contact_group(contact_group)
      assert_raise Ecto.NoResultsError, fn -> Personal.get_contact_group!(contact_group.id) end
    end

    test "change_contact_group/1 returns a contact_group changeset" do
      contact_group = contact_group_fixture()
      assert %Ecto.Changeset{} = Personal.change_contact_group(contact_group)
    end
  end

  describe "memberships" do
    alias Sportyweb.Personal.Membership

    import Sportyweb.PersonalFixtures
    import Sportyweb.OrganizationFixtures

    @invalid_attrs %{state: nil}

    test "list_memberships/1 returns all memberships of a club" do
      club = club_fixture()
      membership_fixture(%{club_id: club.id})
      membership_fixture(%{club_id: club.id})
      membership_fixture()
      assert length(Personal.list_memberships(club.id)) == 2
    end


    test "list_memberships/3 without filter returns all memberships in correct order" do
      club = club_fixture()
      first_membership = membership_fixture(%{start_date: ~D[2000-02-15], club_id: club.id})
      middle_membership = membership_fixture(%{start_date: ~D[2001-02-15], club_id: club.id})
      last_membership = membership_fixture(%{start_date: ~D[2003-02-15], club_id: club.id})

      contacts = Personal.list_memberships(club.id, [asc: :start_date], nil)
      assert contacts == [first_membership, middle_membership, last_membership]

      contacts = Personal.list_memberships(club.id, [desc: :start_date], nil)
      assert contacts == [last_membership, middle_membership, first_membership]
    end

    test "list_memberships/3 with order and filter returns wanted memberships in correct order" do
      club = club_fixture()

      last_membership = membership_fixture(%{start_date: ~D[2003-02-15], club_id: club.id, state: "active"})
      first_membership = membership_fixture(%{start_date: ~D[2000-02-15], club_id: club.id, state: "active"})
      _ = membership_fixture(%{start_date: ~D[2001-02-15], club_id: club.id, state: "pending"})

      memberships =
        Personal.list_memberships(club.id, [asc: :start_date], state: "active")
        assert memberships == [first_membership, last_membership]
    end

    test "list_memberships_of_contact_in returns all matching meberships of a contact" do
     contact = contact_fixture()
     club = club_fixture()
     department = department_fixture(%{club_id: club.id})
     group = group_fixture(%{club_id: club.id, department_id: department.id})

     club_membership  = membership_fixture(%{contact_id: contact.id, club_id: club.id})
     department_membership  = membership_fixture(%{contact_id: contact.id, club_id: club.id, department_id: department.id})
     group_membership  = membership_fixture(%{contact_id: contact.id, club_id: club.id, department_id: department.id, group_id: group.id})

     assert Personal.list_memberships_of_contact_in_club(contact.id, club.id) == [club_membership]
     assert Personal.list_memberships_of_contact_in_department(contact.id, department.id) == [department_membership]
     assert Personal.list_memberships_of_contact_in_group(contact.id, group.id) == [group_membership]
    end

    test "get_membership!/1 returns the membership with given id" do
      membership = membership_fixture()
      assert Personal.get_membership!(membership.id) == membership
    end

    test "create_membership/1 with valid data creates a membership" do
      club = club_fixture()
      contract = contact_fixture()

      valid_attrs = %{
        club_id: club.id,
        contact_id: contract.id,
        start_date: ~D[2000-02-15],
        state: "passiv"
      }

      assert {:ok, %Membership{} = membership} = Personal.create_membership(valid_attrs)
      assert membership.state == "passiv"
    end

    test "create_membership/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Personal.create_membership(@invalid_attrs)
    end

    test "update_membership/2 with valid data updates the membership" do
      membership = membership_fixture()
      update_attrs = %{state: "passiv"}

      assert {:ok, %Membership{} = membership} =
               Personal.update_membership(membership, update_attrs)

      assert membership.state == "passiv"
    end

    test "update_membership/2 with invalid data returns error changeset" do
      membership = membership_fixture()
      assert {:error, %Ecto.Changeset{}} = Personal.update_membership(membership, @invalid_attrs)
      assert membership == Personal.get_membership!(membership.id)
    end

    test "delete_membership/1 deletes the membership" do
      membership = membership_fixture()
      assert {:ok, %Membership{}} = Personal.delete_membership(membership)
      assert_raise Ecto.NoResultsError, fn -> Personal.get_membership!(membership.id) end
    end

    test "change_membership/1 returns a membership changeset" do
      membership = membership_fixture()
      assert %Ecto.Changeset{} = Personal.change_membership(membership)
    end
  end
end
