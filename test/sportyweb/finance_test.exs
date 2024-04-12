defmodule Sportyweb.FinanceTest do
  use Sportyweb.DataCase, async: true

  alias Sportyweb.Finance

  describe "fees" do
    alias Sportyweb.Finance.Fee

    import Sportyweb.FinanceFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PolymorphicFixtures

    @invalid_attrs %{
      commission_date: nil,
      archive_date: nil,
      description: nil,
      is_general: nil,
      is_for_contact_group_contacts_only: nil,
      is_recurring: nil,
      maximum_age_in_years: nil,
      minimum_age_in_years: nil,
      name: nil,
      reference_number: nil,
      type: nil
    }

    test "list_general_fees/2 returns all fees of a given club" do
      fee = fee_fixture()
      assert List.first(Finance.list_general_fees(fee.club_id, "club")).id == fee.id
    end

    test "list_general_fees/3 returns all fees of a given club with preloaded associations" do
      fee = fee_fixture()
      assert Finance.list_general_fees(fee.club_id, "club", [:internal_events, :notes]) == [fee]
    end

    test "get_fee!/1 returns the fee with given id" do
      fee = fee_fixture()
      assert Finance.get_fee!(fee.id).id == fee.id
    end

    test "get_fee!/2 returns the fee with given id and contains preloaded associations" do
      fee = fee_fixture()
      assert Finance.get_fee!(fee.id, [:internal_events, :notes]) == fee
    end

    test "create_fee/1 with valid data creates a fee" do
      club = club_fixture()

      valid_attrs = %{
        club_id: club.id,
        amount: "42 €",
        amount_one_time: "15 €",
        description: "some description",
        is_for_contact_group_contacts_only: true,
        is_general: true,
        maximum_age_in_years: 25,
        minimum_age_in_years: 15,
        name: "some name",
        reference_number: "some reference_number",
        type: "club",
        internal_events: [internal_event_attrs()],
        notes: [note_attrs()]
      }

      assert {:ok, %Fee{} = fee} = Finance.create_fee(valid_attrs)
      assert fee.amount == Money.new(:EUR, 42)
      assert fee.amount_one_time == Money.new(:EUR, 15)
      assert fee.description == "some description"
      assert fee.is_for_contact_group_contacts_only == true
      assert fee.is_general == true
      assert fee.maximum_age_in_years == 25
      assert fee.minimum_age_in_years == 15
      assert fee.name == "some name"
      assert fee.reference_number == "some reference_number"
      assert fee.type == "club"
    end

    test "create_fee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finance.create_fee(@invalid_attrs)
    end

    test "update_fee/2 with valid data updates the fee" do
      fee = fee_fixture()

      update_attrs = %{
        amount: "50 €",
        amount_one_time: "20 €",
        description: "some updated description",
        is_for_contact_group_contacts_only: false,
        is_general: false,
        maximum_age_in_years: 30,
        minimum_age_in_years: 20,
        name: "some updated name",
        reference_number: "some updated reference_number",
        type: "department"
      }

      assert {:ok, %Fee{} = fee} = Finance.update_fee(fee, update_attrs)
      assert fee.amount == Money.new(:EUR, 50)
      assert fee.amount_one_time == Money.new(:EUR, 20)
      assert fee.description == "some updated description"
      assert fee.is_for_contact_group_contacts_only == false
      assert fee.is_general == false
      assert fee.maximum_age_in_years == 30
      assert fee.minimum_age_in_years == 20
      assert fee.name == "some updated name"
      assert fee.reference_number == "some updated reference_number"
      assert fee.type == "department"
    end

    test "update_fee/2 with invalid data returns error changeset" do
      fee = fee_fixture()
      assert {:error, %Ecto.Changeset{}} = Finance.update_fee(fee, @invalid_attrs)
      assert fee == Finance.get_fee!(fee.id, [:internal_events, :notes])
    end

    test "delete_fee/1 deletes the fee" do
      fee = fee_fixture()
      assert {:ok, %Fee{}} = Finance.delete_fee(fee)
      assert_raise Ecto.NoResultsError, fn -> Finance.get_fee!(fee.id) end
    end

    test "change_fee/1 returns a fee changeset" do
      fee = fee_fixture()
      assert %Ecto.Changeset{} = Finance.change_fee(fee)
    end
  end

  describe "subsidies" do
    alias Sportyweb.Finance.Subsidy

    import Sportyweb.FinanceFixtures
    import Sportyweb.OrganizationFixtures
    import Sportyweb.PolymorphicFixtures

    @invalid_attrs %{
      amount: nil,
      description: nil,
      name: nil,
      reference_number: nil
    }

    test "list_subsidies/1 returns all subsidies of a given club" do
      subsidy = subsidy_fixture()
      assert List.first(Finance.list_subsidies(subsidy.club_id)).id == subsidy.id
    end

    test "list_subsidies/2 returns all subsidies of a given club with preloaded associations" do
      subsidy = subsidy_fixture()
      assert Finance.list_subsidies(subsidy.club_id, [:notes, :internal_events]) == [subsidy]
    end

    test "get_subsidy!/1 returns the subsidy with given id" do
      subsidy = subsidy_fixture()
      assert Finance.get_subsidy!(subsidy.id).id == subsidy.id
    end

    test "get_subsidy!/2 returns the subsidy with given id and contains preloaded associations" do
      subsidy = subsidy_fixture()
      assert Finance.get_subsidy!(subsidy.id, [:notes, :internal_events]) == subsidy
    end

    test "create_subsidy/1 with valid data creates a subsidy" do
      club = club_fixture()

      valid_attrs = %{
        club_id: club.id,
        amount: "42 €",
        description: "some description",
        name: "some name",
        reference_number: "some reference_number",
        internal_events: [internal_event_attrs()],
        notes: [note_attrs()]
      }

      assert {:ok, %Subsidy{} = subsidy} = Finance.create_subsidy(valid_attrs)
      assert subsidy.amount == Money.new(:EUR, 42)
      assert subsidy.description == "some description"
      assert subsidy.name == "some name"
      assert subsidy.reference_number == "some reference_number"
    end

    test "create_subsidy/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finance.create_subsidy(@invalid_attrs)
    end

    test "update_subsidy/2 with valid data updates the subsidy" do
      subsidy = subsidy_fixture()

      update_attrs = %{
        amount: "43 €",
        description: "some updated description",
        name: "some updated name",
        reference_number: "some updated reference_number"
      }

      assert {:ok, %Subsidy{} = subsidy} = Finance.update_subsidy(subsidy, update_attrs)
      assert subsidy.amount == Money.new(:EUR, 43)
      assert subsidy.description == "some updated description"
      assert subsidy.name == "some updated name"
      assert subsidy.reference_number == "some updated reference_number"
    end

    test "update_subsidy/2 with invalid data returns error changeset" do
      subsidy = subsidy_fixture()
      assert {:error, %Ecto.Changeset{}} = Finance.update_subsidy(subsidy, @invalid_attrs)
      assert subsidy == Finance.get_subsidy!(subsidy.id, [:internal_events, :notes])
    end

    test "delete_subsidy/1 deletes the subsidy" do
      subsidy = subsidy_fixture()
      assert {:ok, %Subsidy{}} = Finance.delete_subsidy(subsidy)
      assert_raise Ecto.NoResultsError, fn -> Finance.get_subsidy!(subsidy.id) end
    end

    test "change_subsidy/1 returns a subsidy changeset" do
      subsidy = subsidy_fixture()
      assert %Ecto.Changeset{} = Finance.change_subsidy(subsidy)
    end
  end
end
