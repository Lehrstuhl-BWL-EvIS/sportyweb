defmodule Sportyweb.CalendarTest do
  use Sportyweb.DataCase

  alias Sportyweb.Calendar

  describe "events" do
    alias Sportyweb.Calendar.Event
    alias Sportyweb.Calendar.EventFee

    import Sportyweb.CalendarFixtures
    import Sportyweb.FinanceFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PolymorphicFixtures

    @invalid_attrs %{
      description: nil,
      location_type: nil,
      maximum_age_in_years: 5,
      maximum_participants: "",
      minimum_age_in_years: 80,
      minimum_participants: "",
      name: nil,
      reference_number: nil,
      status: nil
    }

    test "list_events/1 returns all events of a given club" do
      event = event_fixture()
      assert List.first(Calendar.list_events(event.club_id)).id == event.id
    end

    test "list_events/2 returns all events of a given club with preloaded associations" do
      event = event_fixture()
      assert Calendar.list_events(event.club_id, [:emails, :phones, :notes]) == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Calendar.get_event!(event.id).id == event.id
    end

    test "get_event!/2 returns the event with given id and contains preloaded associations" do
      event = event_fixture()
      assert Calendar.get_event!(event.id, [:emails, :phones, :notes]) == event
    end

    test "create_event/1 with valid data creates a event" do
      club = club_fixture()

      valid_attrs = %{
        club_id: club.id,
        description: "some description",
        location_type: "no_info",
        maximum_age_in_years: 65,
        maximum_participants: 15,
        minimum_age_in_years: 18,
        minimum_participants: 10,
        name: "some name",
        reference_number: "some reference_number",
        status: "draft",
        emails: [email_attrs()],
        phones: [phone_attrs()],
        notes: [note_attrs()]
      }

      assert {:ok, %Event{} = event} = Calendar.create_event(valid_attrs)
      assert event.description == "some description"
      assert event.location_type == "no_info"
      assert event.maximum_age_in_years == 65
      assert event.maximum_participants == 15
      assert event.minimum_age_in_years == 18
      assert event.minimum_participants == 10
      assert event.name == "some name"
      assert event.reference_number == "some reference_number"
      assert event.status == "draft"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Calendar.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()

      update_attrs = %{
        description: "some updated description",
        maximum_age_in_years: nil,
        maximum_participants: 20,
        minimum_age_in_years: 45,
        minimum_participants: nil,
        name: "some updated name",
        reference_number: "some updated reference_number",
        status: "cancelled"
      }

      assert {:ok, %Event{} = event} = Calendar.update_event(event, update_attrs)
      assert event.description == "some updated description"
      assert event.maximum_age_in_years == nil
      assert event.maximum_participants == 20
      assert event.minimum_age_in_years == 45
      assert event.minimum_participants == nil
      assert event.name == "some updated name"
      assert event.reference_number == "some updated reference_number"
      assert event.status == "cancelled"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Calendar.update_event(event, @invalid_attrs)
      assert event == Calendar.get_event!(event.id, [:emails, :phones, :notes])
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Calendar.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Calendar.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Calendar.change_event(event)
    end

    test "create_event_fee/2 with valid data" do
      event = event_fixture()
      fee = fee_fixture()
      assert {:ok, %EventFee{}} = Calendar.create_event_fee(event, fee)
    end
  end
end
