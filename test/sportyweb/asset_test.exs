defmodule Sportyweb.AssetTest do
  use Sportyweb.DataCase

  alias Sportyweb.Asset

  describe "venues" do
    alias Sportyweb.Asset.Venue

    import Sportyweb.AssetFixtures
    import Sportyweb.OrganizationFixtures

    @invalid_attrs %{
      description: nil,
      name: nil,
      reference_number: nil
    }

    test "list_venues/1 returns all venues of a given club" do
      venue = venue_fixture()
      assert Asset.list_venues(venue.club_id) == [venue]
    end

    test "list_venues/2 returns all venues of a given club with preloaded associations" do
      equipment = equipment_fixture()
      venue = Asset.get_venue!(equipment.venue_id)

      venues = Asset.list_venues(venue.club_id, [:equipment])
      assert List.first(venues).equipment == [equipment]
    end

    test "get_venue!/1 returns the venue with given id" do
      venue = venue_fixture()
      assert Asset.get_venue!(venue.id).id == venue.id
    end

    test "create_venue/1 with valid data creates a venue" do
      club = club_fixture()

      valid_attrs = %{
        club_id: club.id,
        description: "some description",
        name: "some name",
        reference_number: "some reference_number"
      }

      assert {:ok, %Venue{} = venue} = Asset.create_venue(valid_attrs)
      assert venue.description == "some description"
      assert venue.name == "some name"
      assert venue.reference_number == "some reference_number"
    end

    test "create_venue/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Asset.create_venue(@invalid_attrs)
    end

    test "update_venue/2 with valid data updates the venue" do
      venue = venue_fixture()

      update_attrs = %{
        description: "some updated description",
        name: "some updated name",
        reference_number: "some updated reference_number"
      }

      assert {:ok, %Venue{} = venue} = Asset.update_venue(venue, update_attrs)
      assert venue.description == "some updated description"
      assert venue.name == "some updated name"
      assert venue.reference_number == "some updated reference_number"
    end

    test "update_venue/2 with invalid data returns error changeset" do
      venue = venue_fixture()
      assert {:error, %Ecto.Changeset{}} = Asset.update_venue(venue, @invalid_attrs)
      assert venue.id == Asset.get_venue!(venue.id).id
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

  describe "equipment" do
    alias Sportyweb.Asset.Equipment

    import Sportyweb.AssetFixtures

    @invalid_attrs %{
      commission_date: nil,
      decommission_date: nil,
      description: nil,
      name: nil,
      purchase_date: nil,
      reference_number: nil,
      serial_number: nil
    }

    test "list_equipment/0 returns all equipment" do
      equipment = equipment_fixture()
      assert Asset.list_equipment(equipment.venue_id) == [equipment]
    end

    test "get_equipment!/1 returns the equipment with given id" do
      equipment = equipment_fixture()
      assert Asset.get_equipment!(equipment.id) == equipment
    end

    test "create_equipment/1 with valid data creates a equipment" do
      venue = venue_fixture()

      valid_attrs = %{
        venue_id: venue.id,
        commission_date: ~D[2023-02-14],
        decommission_date: ~D[2023-02-14],
        description: "some description",
        name: "some name",
        purchase_date: ~D[2023-02-14],
        reference_number: "some reference_number",
        serial_number: "some serial_number"
      }

      assert {:ok, %Equipment{} = equipment} = Asset.create_equipment(valid_attrs)
      assert equipment.commission_date == ~D[2023-02-14]
      assert equipment.decommission_date == ~D[2023-02-14]
      assert equipment.description == "some description"
      assert equipment.name == "some name"
      assert equipment.purchase_date == ~D[2023-02-14]
      assert equipment.reference_number == "some reference_number"
      assert equipment.serial_number == "some serial_number"
    end

    test "create_equipment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Asset.create_equipment(@invalid_attrs)
    end

    test "update_equipment/2 with valid data updates the equipment" do
      equipment = equipment_fixture()

      update_attrs = %{
        commission_date: ~D[2023-02-15],
        decommission_date: ~D[2023-02-15],
        description: "some updated description",
        name: "some updated name",
        purchase_date: ~D[2023-02-15],
        reference_number: "some updated reference_number",
        serial_number: "some updated serial_number"
      }

      assert {:ok, %Equipment{} = equipment} = Asset.update_equipment(equipment, update_attrs)
      assert equipment.commission_date == ~D[2023-02-15]
      assert equipment.decommission_date == ~D[2023-02-15]
      assert equipment.description == "some updated description"
      assert equipment.name == "some updated name"
      assert equipment.purchase_date == ~D[2023-02-15]
      assert equipment.reference_number == "some updated reference_number"
      assert equipment.serial_number == "some updated serial_number"
    end

    test "update_equipment/2 with invalid data returns error changeset" do
      equipment = equipment_fixture()
      assert {:error, %Ecto.Changeset{}} = Asset.update_equipment(equipment, @invalid_attrs)
      assert equipment == Asset.get_equipment!(equipment.id)
    end

    test "delete_equipment/1 deletes the equipment" do
      equipment = equipment_fixture()
      assert {:ok, %Equipment{}} = Asset.delete_equipment(equipment)
      assert_raise Ecto.NoResultsError, fn -> Asset.get_equipment!(equipment.id) end
    end

    test "change_equipment/1 returns a equipment changeset" do
      equipment = equipment_fixture()
      assert %Ecto.Changeset{} = Asset.change_equipment(equipment)
    end
  end
end
