defmodule Sportyweb.AssetTest do
  use Sportyweb.DataCase

  alias Sportyweb.Asset

  describe "venues" do
    alias Sportyweb.Asset.Venue

    import Sportyweb.AssetFixtures

    @invalid_attrs %{description: nil, is_main: nil, name: nil, reference_number: nil}

    test "list_venues/0 returns all venues" do
      venue = venue_fixture()
      assert Asset.list_venues() == [venue]
    end

    test "get_venue!/1 returns the venue with given id" do
      venue = venue_fixture()
      assert Asset.get_venue!(venue.id) == venue
    end

    test "create_venue/1 with valid data creates a venue" do
      valid_attrs = %{description: "some description", is_main: true, name: "some name", reference_number: "some reference_number"}

      assert {:ok, %Venue{} = venue} = Asset.create_venue(valid_attrs)
      assert venue.description == "some description"
      assert venue.is_main == true
      assert venue.name == "some name"
      assert venue.reference_number == "some reference_number"
    end

    test "create_venue/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Asset.create_venue(@invalid_attrs)
    end

    test "update_venue/2 with valid data updates the venue" do
      venue = venue_fixture()
      update_attrs = %{description: "some updated description", is_main: false, name: "some updated name", reference_number: "some updated reference_number"}

      assert {:ok, %Venue{} = venue} = Asset.update_venue(venue, update_attrs)
      assert venue.description == "some updated description"
      assert venue.is_main == false
      assert venue.name == "some updated name"
      assert venue.reference_number == "some updated reference_number"
    end

    test "update_venue/2 with invalid data returns error changeset" do
      venue = venue_fixture()
      assert {:error, %Ecto.Changeset{}} = Asset.update_venue(venue, @invalid_attrs)
      assert venue == Asset.get_venue!(venue.id)
    end

    test "delete_venue/1 deletes the venue" do
      venue = venue_fixture()
      assert {:ok, %Venue{}} = Asset.delete_venue(venue)
      assert_raise Ecto.NoResultsError, fn -> Asset.get_venue!(venue.id) end
    end

    test "change_venue/1 returns a venue changeset" do
      venue = venue_fixture()
      assert %Ecto.Changeset{} = Asset.change_venue(venue)
    end
  end
end
