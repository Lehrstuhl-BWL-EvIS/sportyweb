defmodule Sportyweb.MembershipTest do
  use Sportyweb.DataCase

  alias Sportyweb.Membership

  describe "members" do
    alias Sportyweb.Membership.Member

    import Sportyweb.MembershipFixtures

    @invalid_attrs %{date_of_birth: nil, email1: nil, email2: nil, firstname: nil, gender: nil, is_active: nil, lastname: nil, phone1: nil, phone2: nil}

    test "list_members/0 returns all members" do
      member = member_fixture()
      assert Membership.list_members() == [member]
    end

    test "get_member!/1 returns the member with given id" do
      member = member_fixture()
      assert Membership.get_member!(member.id) == member
    end

    test "create_member/1 with valid data creates a member" do
      valid_attrs = %{date_of_birth: ~D[2022-08-24], email1: "some email1", email2: "some email2", firstname: "some firstname", gender: "some gender", is_active: true, lastname: "some lastname", phone1: "some phone1", phone2: "some phone2"}

      assert {:ok, %Member{} = member} = Membership.create_member(valid_attrs)
      assert member.date_of_birth == ~D[2022-08-24]
      assert member.email1 == "some email1"
      assert member.email2 == "some email2"
      assert member.firstname == "some firstname"
      assert member.gender == "some gender"
      assert member.is_active == true
      assert member.lastname == "some lastname"
      assert member.phone1 == "some phone1"
      assert member.phone2 == "some phone2"
    end

    test "create_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Membership.create_member(@invalid_attrs)
    end

    test "update_member/2 with valid data updates the member" do
      member = member_fixture()
      update_attrs = %{date_of_birth: ~D[2022-08-25], email1: "some updated email1", email2: "some updated email2", firstname: "some updated firstname", gender: "some updated gender", is_active: false, lastname: "some updated lastname", phone1: "some updated phone1", phone2: "some updated phone2"}

      assert {:ok, %Member{} = member} = Membership.update_member(member, update_attrs)
      assert member.date_of_birth == ~D[2022-08-25]
      assert member.email1 == "some updated email1"
      assert member.email2 == "some updated email2"
      assert member.firstname == "some updated firstname"
      assert member.gender == "some updated gender"
      assert member.is_active == false
      assert member.lastname == "some updated lastname"
      assert member.phone1 == "some updated phone1"
      assert member.phone2 == "some updated phone2"
    end

    test "update_member/2 with invalid data returns error changeset" do
      member = member_fixture()
      assert {:error, %Ecto.Changeset{}} = Membership.update_member(member, @invalid_attrs)
      assert member == Membership.get_member!(member.id)
    end

    test "delete_member/1 deletes the member" do
      member = member_fixture()
      assert {:ok, %Member{}} = Membership.delete_member(member)
      assert_raise Ecto.NoResultsError, fn -> Membership.get_member!(member.id) end
    end

    test "change_member/1 returns a member changeset" do
      member = member_fixture()
      assert %Ecto.Changeset{} = Membership.change_member(member)
    end
  end
end
