defmodule Sportyweb.LegalTest do
  use Sportyweb.DataCase

  alias Sportyweb.Legal

  describe "fees" do
    alias Sportyweb.Legal.Fee

    import Sportyweb.LegalFixtures
    import Sportyweb.OrganizationFixtures

    @invalid_attrs %{admission_fee_in_eur: nil, admission_fee_in_eur_cent: nil, base_fee_in_eur: nil, base_fee_in_eur_cent: nil, commission_date: nil, archive_date: nil, description: nil, is_general: nil, is_for_contact_group_contacts_only: nil, is_recurring: nil, maximum_age_in_years: nil, minimum_age_in_years: nil, name: nil, reference_number: nil, type: nil}

    test "list_fees/0 returns all fees" do
      fee = fee_fixture()
      assert Legal.list_general_fees(fee.club_id, "club") == [fee]
    end

    test "get_fee!/1 returns the fee with given id" do
      fee = fee_fixture()
      assert Legal.get_fee!(fee.id) == fee
    end

    test "create_fee/1 with valid data creates a fee" do
      club = club_fixture()
      valid_attrs = %{club_id: club.id, admission_fee_in_eur: 15, admission_fee_in_eur_cent: 1500, base_fee_in_eur: 42, base_fee_in_eur_cent: 4200, commission_date: ~D[2023-02-24], archive_date: ~D[2023-02-24], description: "some description", is_general: true, is_for_contact_group_contacts_only: true, is_recurring: true, maximum_age_in_years: 42, minimum_age_in_years: 42, name: "some name", reference_number: "some reference_number", type: "club"}

      assert {:ok, %Fee{} = fee} = Legal.create_fee(valid_attrs)
      assert fee.admission_fee_in_eur_cent == 1500
      assert fee.base_fee_in_eur_cent == 4200
      assert fee.commission_date == ~D[2023-02-24]
      assert fee.archive_date == ~D[2023-02-24]
      assert fee.description == "some description"
      assert fee.is_general == true
      assert fee.is_for_contact_group_contacts_only == true
      assert fee.is_recurring == true
      assert fee.maximum_age_in_years == 42
      assert fee.minimum_age_in_years == 42
      assert fee.name == "some name"
      assert fee.reference_number == "some reference_number"
      assert fee.type == "club"
    end

    test "create_fee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Legal.create_fee(@invalid_attrs)
    end

    test "update_fee/2 with valid data updates the fee" do
      fee = fee_fixture()
      update_attrs = %{admission_fee_in_eur: 16, admission_fee_in_eur_cent: 1600, base_fee_in_eur: 43, base_fee_in_eur_cent: 4300, commission_date: ~D[2023-02-25], archive_date: ~D[2023-02-25], description: "some updated description", is_general: false, is_for_contact_group_contacts_only: false, is_recurring: false, maximum_age_in_years: 43, minimum_age_in_years: 43, name: "some updated name", reference_number: "some updated reference_number", type: "department"}

      assert {:ok, %Fee{} = fee} = Legal.update_fee(fee, update_attrs)
      assert fee.admission_fee_in_eur_cent == 1600
      assert fee.base_fee_in_eur_cent == 4300
      assert fee.commission_date == ~D[2023-02-25]
      assert fee.archive_date == ~D[2023-02-25]
      assert fee.description == "some updated description"
      assert fee.is_general == false
      assert fee.is_for_contact_group_contacts_only == false
      assert fee.is_recurring == false
      assert fee.maximum_age_in_years == 43
      assert fee.minimum_age_in_years == 43
      assert fee.name == "some updated name"
      assert fee.reference_number == "some updated reference_number"
      assert fee.type == "department"
    end

    test "update_fee/2 with invalid data returns error changeset" do
      fee = fee_fixture()
      assert {:error, %Ecto.Changeset{}} = Legal.update_fee(fee, @invalid_attrs)
      assert fee == Legal.get_fee!(fee.id)
    end

    test "delete_fee/1 deletes the fee" do
      fee = fee_fixture()
      assert {:ok, %Fee{}} = Legal.delete_fee(fee)
      assert_raise Ecto.NoResultsError, fn -> Legal.get_fee!(fee.id) end
    end

    test "change_fee/1 returns a fee changeset" do
      fee = fee_fixture()
      assert %Ecto.Changeset{} = Legal.change_fee(fee)
    end
  end

  describe "subsidies" do
    alias Sportyweb.Legal.Subsidy

    import Sportyweb.LegalFixtures

    @invalid_attrs %{archive_date: nil, commission_date: nil, description: nil, name: nil, reference_number: nil, value: nil}

    test "list_subsidies/0 returns all subsidies" do
      subsidy = subsidy_fixture()
      assert Legal.list_subsidies() == [subsidy]
    end

    test "get_subsidy!/1 returns the subsidy with given id" do
      subsidy = subsidy_fixture()
      assert Legal.get_subsidy!(subsidy.id) == subsidy
    end

    test "create_subsidy/1 with valid data creates a subsidy" do
      valid_attrs = %{archive_date: ~D[2023-05-29], commission_date: ~D[2023-05-29], description: "some description", name: "some name", reference_number: "some reference_number", value: 42}

      assert {:ok, %Subsidy{} = subsidy} = Legal.create_subsidy(valid_attrs)
      assert subsidy.archive_date == ~D[2023-05-29]
      assert subsidy.commission_date == ~D[2023-05-29]
      assert subsidy.description == "some description"
      assert subsidy.name == "some name"
      assert subsidy.reference_number == "some reference_number"
      assert subsidy.value == 42
    end

    test "create_subsidy/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Legal.create_subsidy(@invalid_attrs)
    end

    test "update_subsidy/2 with valid data updates the subsidy" do
      subsidy = subsidy_fixture()
      update_attrs = %{archive_date: ~D[2023-05-30], commission_date: ~D[2023-05-30], description: "some updated description", name: "some updated name", reference_number: "some updated reference_number", value: 43}

      assert {:ok, %Subsidy{} = subsidy} = Legal.update_subsidy(subsidy, update_attrs)
      assert subsidy.archive_date == ~D[2023-05-30]
      assert subsidy.commission_date == ~D[2023-05-30]
      assert subsidy.description == "some updated description"
      assert subsidy.name == "some updated name"
      assert subsidy.reference_number == "some updated reference_number"
      assert subsidy.value == 43
    end

    test "update_subsidy/2 with invalid data returns error changeset" do
      subsidy = subsidy_fixture()
      assert {:error, %Ecto.Changeset{}} = Legal.update_subsidy(subsidy, @invalid_attrs)
      assert subsidy == Legal.get_subsidy!(subsidy.id)
    end

    test "delete_subsidy/1 deletes the subsidy" do
      subsidy = subsidy_fixture()
      assert {:ok, %Subsidy{}} = Legal.delete_subsidy(subsidy)
      assert_raise Ecto.NoResultsError, fn -> Legal.get_subsidy!(subsidy.id) end
    end

    test "change_subsidy/1 returns a subsidy changeset" do
      subsidy = subsidy_fixture()
      assert %Ecto.Changeset{} = Legal.change_subsidy(subsidy)
    end
  end
end
