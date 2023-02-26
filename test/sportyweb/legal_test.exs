defmodule Sportyweb.LegalTest do
  use Sportyweb.DataCase

  alias Sportyweb.Legal

  describe "fees" do
    alias Sportyweb.Legal.Fee

    import Sportyweb.LegalFixtures

    @invalid_attrs %{admission_fee_in_eur_cent: nil, base_fee_in_eur_cent: nil, commission_at: nil, decommission_at: nil, description: nil, is_group_only: nil, is_recurring: nil, maximum_age_in_years: nil, minimum_age_in_years: nil, name: nil, reference_number: nil, type: nil}

    test "list_fees/0 returns all fees" do
      fee = fee_fixture()
      assert Legal.list_fees() == [fee]
    end

    test "get_fee!/1 returns the fee with given id" do
      fee = fee_fixture()
      assert Legal.get_fee!(fee.id) == fee
    end

    test "create_fee/1 with valid data creates a fee" do
      valid_attrs = %{admission_fee_in_eur_cent: 42, base_fee_in_eur_cent: 42, commission_at: ~D[2023-02-24], decommission_at: ~D[2023-02-24], description: "some description", is_group_only: true, is_recurring: true, maximum_age_in_years: 42, minimum_age_in_years: 42, name: "some name", reference_number: "some reference_number", type: "some type"}

      assert {:ok, %Fee{} = fee} = Legal.create_fee(valid_attrs)
      assert fee.admission_fee_in_eur_cent == 42
      assert fee.base_fee_in_eur_cent == 42
      assert fee.commission_at == ~D[2023-02-24]
      assert fee.decommission_at == ~D[2023-02-24]
      assert fee.description == "some description"
      assert fee.is_group_only == true
      assert fee.is_recurring == true
      assert fee.maximum_age_in_years == 42
      assert fee.minimum_age_in_years == 42
      assert fee.name == "some name"
      assert fee.reference_number == "some reference_number"
      assert fee.type == "some type"
    end

    test "create_fee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Legal.create_fee(@invalid_attrs)
    end

    test "update_fee/2 with valid data updates the fee" do
      fee = fee_fixture()
      update_attrs = %{admission_fee_in_eur_cent: 43, base_fee_in_eur_cent: 43, commission_at: ~D[2023-02-25], decommission_at: ~D[2023-02-25], description: "some updated description", is_group_only: false, is_recurring: false, maximum_age_in_years: 43, minimum_age_in_years: 43, name: "some updated name", reference_number: "some updated reference_number", type: "some updated type"}

      assert {:ok, %Fee{} = fee} = Legal.update_fee(fee, update_attrs)
      assert fee.admission_fee_in_eur_cent == 43
      assert fee.base_fee_in_eur_cent == 43
      assert fee.commission_at == ~D[2023-02-25]
      assert fee.decommission_at == ~D[2023-02-25]
      assert fee.description == "some updated description"
      assert fee.is_group_only == false
      assert fee.is_recurring == false
      assert fee.maximum_age_in_years == 43
      assert fee.minimum_age_in_years == 43
      assert fee.name == "some updated name"
      assert fee.reference_number == "some updated reference_number"
      assert fee.type == "some updated type"
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
end
