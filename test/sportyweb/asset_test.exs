defmodule Sportyweb.AssetTest do
  use Sportyweb.DataCase, async: true

  alias Sportyweb.Asset

  describe "locations" do
    alias Sportyweb.Asset.Location
    alias Sportyweb.Asset.LocationFee

    import Sportyweb.AssetFixtures
    import Sportyweb.FinanceFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PolymorphicFixtures

    @invalid_attrs %{
      description: nil,
      name: nil,
      reference_number: nil
    }

    test "list_locations/1 returns all locations of a given club" do
      location = location_fixture()
      assert List.first(Asset.list_locations(location.club_id)).id == location.id
    end

    test "list_locations/2 returns all locations of a given club with preloaded associations" do
      location = location_fixture()

      assert Asset.list_locations(location.club_id, [:emails, :notes, :phones, :postal_addresses]) ==
               [
                 location
               ]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert Asset.get_location!(location.id).id == location.id
    end

    test "get_location!/2 returns the location with given id and contains preloaded associations" do
      location = location_fixture()

      assert Asset.get_location!(location.id, [:emails, :notes, :phones, :postal_addresses]) ==
               location
    end

    test "create_location/1 with valid data creates a location" do
      club = club_fixture()

      valid_attrs = %{
        club_id: club.id,
        description: "some description",
        name: "some name",
        reference_number: "some reference_number",
        emails: [email_attrs()],
        notes: [note_attrs()],
        phones: [phone_attrs()],
        postal_addresses: [postal_address_attrs()]
      }

      assert {:ok, %Location{} = location} = Asset.create_location(valid_attrs)
      assert location.description == "some description"
      assert location.name == "some name"
      assert location.reference_number == "some reference_number"
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Asset.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()

      update_attrs = %{
        description: "some updated description",
        name: "some updated name",
        reference_number: "some updated reference_number"
      }

      assert {:ok, %Location{} = location} = Asset.update_location(location, update_attrs)
      assert location.description == "some updated description"
      assert location.name == "some updated name"
      assert location.reference_number == "some updated reference_number"
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Asset.update_location(location, @invalid_attrs)
      assert location.id == Asset.get_location!(location.id).id
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = Asset.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Asset.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Asset.change_location(location)
    end

    test "create_location_fee/2 with valid data" do
      location = location_fixture()
      fee = fee_fixture()
      assert {:ok, %LocationFee{}} = Asset.create_location_fee(location, fee)
    end
  end

  describe "equipment" do
    alias Sportyweb.Asset.Equipment
    alias Sportyweb.Asset.EquipmentFee

    import Sportyweb.AssetFixtures
    import Sportyweb.FinanceFixtures
    import Sportyweb.PolymorphicFixtures

    @invalid_attrs %{
      commission_date: nil,
      decommission_date: nil,
      description: nil,
      name: nil,
      purchase_date: nil,
      reference_number: nil,
      serial_number: nil
    }

    test "list_equipment/1 returns all equipment of a given location" do
      equipment = equipment_fixture()
      assert List.first(Asset.list_equipment(equipment.location_id)).id == equipment.id
    end

    test "list_equipment/2 returns all equipment of a given location with preloaded associations" do
      equipment = equipment_fixture()

      assert Asset.list_equipment(equipment.location_id, [:emails, :notes, :phones]) == [
               equipment
             ]
    end

    test "get_equipment!/1 returns the equipment with given id" do
      equipment = equipment_fixture()
      assert Asset.get_equipment!(equipment.id).id == equipment.id
    end

    test "get_equipment!/2 returns the equipment with given id and contains preloaded associations" do
      equipment = equipment_fixture()
      assert Asset.get_equipment!(equipment.id, [:emails, :notes, :phones]) == equipment
    end

    test "create_equipment/1 with valid data creates a equipment" do
      location = location_fixture()

      valid_attrs = %{
        location_id: location.id,
        commission_date: ~D[2023-02-14],
        decommission_date: ~D[2023-02-14],
        description: "some description",
        name: "some name",
        purchase_date: ~D[2023-02-14],
        reference_number: "some reference_number",
        serial_number: "some serial_number",
        emails: [email_attrs()],
        notes: [note_attrs()],
        phones: [phone_attrs()]
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
      assert equipment == Asset.get_equipment!(equipment.id, [:emails, :phones, :notes])
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

    test "create_equipment_fee/2 with valid data" do
      equipment = equipment_fixture()
      fee = fee_fixture()
      assert {:ok, %EquipmentFee{}} = Asset.create_equipment_fee(equipment, fee)
    end
  end
end
