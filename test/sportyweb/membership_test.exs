defmodule Sportyweb.MembershipTest do
  use Sportyweb.DataCase

  alias Sportyweb.Membership

  describe "households" do
    alias Sportyweb.Membership.Household

    import Sportyweb.MembershipFixtures

    @invalid_attrs %{identifier: nil}

    test "list_households/0 returns all households" do
      household = household_fixture()
      assert Membership.list_households() == [household]
    end

    test "get_household!/1 returns the household with given id" do
      household = household_fixture()
      assert Membership.get_household!(household.id) == household
    end

    test "create_household/1 with valid data creates a household" do
      valid_attrs = %{identifier: "some identifier"}

      assert {:ok, %Household{} = household} = Membership.create_household(valid_attrs)
      assert household.identifier == "some identifier"
    end

    test "create_household/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Membership.create_household(@invalid_attrs)
    end

    test "update_household/2 with valid data updates the household" do
      household = household_fixture()
      update_attrs = %{identifier: "some updated identifier"}

      assert {:ok, %Household{} = household} = Membership.update_household(household, update_attrs)
      assert household.identifier == "some updated identifier"
    end

    test "update_household/2 with invalid data returns error changeset" do
      household = household_fixture()
      assert {:error, %Ecto.Changeset{}} = Membership.update_household(household, @invalid_attrs)
      assert household == Membership.get_household!(household.id)
    end

    test "delete_household/1 deletes the household" do
      household = household_fixture()
      assert {:ok, %Household{}} = Membership.delete_household(household)
      assert_raise Ecto.NoResultsError, fn -> Membership.get_household!(household.id) end
    end

    test "change_household/1 returns a household changeset" do
      household = household_fixture()
      assert %Ecto.Changeset{} = Membership.change_household(household)
    end
  end
end
