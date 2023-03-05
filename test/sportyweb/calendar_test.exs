defmodule Sportyweb.CalendarTest do
  use Sportyweb.DataCase

  alias Sportyweb.Calendar

  describe "events" do
    alias Sportyweb.Calendar.Event

    import Sportyweb.CalendarFixtures

    @invalid_attrs %{description: nil, location_description: nil, location_type: nil, maximum_age_in_years: nil, maximum_participants: nil, minimum_age_in_years: nil, minimum_participants: nil, name: nil, reference_number: nil, status: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Calendar.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Calendar.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{description: "some description", location_description: "some location_description", location_type: "some location_type", maximum_age_in_years: 42, maximum_participants: 42, minimum_age_in_years: 42, minimum_participants: 42, name: "some name", reference_number: "some reference_number", status: "some status"}

      assert {:ok, %Event{} = event} = Calendar.create_event(valid_attrs)
      assert event.description == "some description"
      assert event.location_description == "some location_description"
      assert event.location_type == "some location_type"
      assert event.maximum_age_in_years == 42
      assert event.maximum_participants == 42
      assert event.minimum_age_in_years == 42
      assert event.minimum_participants == 42
      assert event.name == "some name"
      assert event.reference_number == "some reference_number"
      assert event.status == "some status"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Calendar.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      update_attrs = %{description: "some updated description", location_description: "some updated location_description", location_type: "some updated location_type", maximum_age_in_years: 43, maximum_participants: 43, minimum_age_in_years: 43, minimum_participants: 43, name: "some updated name", reference_number: "some updated reference_number", status: "some updated status"}

      assert {:ok, %Event{} = event} = Calendar.update_event(event, update_attrs)
      assert event.description == "some updated description"
      assert event.location_description == "some updated location_description"
      assert event.location_type == "some updated location_type"
      assert event.maximum_age_in_years == 43
      assert event.maximum_participants == 43
      assert event.minimum_age_in_years == 43
      assert event.minimum_participants == 43
      assert event.name == "some updated name"
      assert event.reference_number == "some updated reference_number"
      assert event.status == "some updated status"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Calendar.update_event(event, @invalid_attrs)
      assert event == Calendar.get_event!(event.id)
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
  end
end
