defmodule Sportyweb.OrganizationsTest do
  use Sportyweb.DataCase

  alias Sportyweb.Organizations

  describe "clubs" do
    alias Sportyweb.Organizations.Club

    import Sportyweb.OrganizationsFixtures

    @invalid_attrs %{founding_date: nil, name: nil, reference_number: nil, website_url: nil}

    test "list_clubs/0 returns all clubs" do
      club = club_fixture()
      assert Organizations.list_clubs() == [club]
    end

    test "get_club!/1 returns the club with given id" do
      club = club_fixture()
      assert Organizations.get_club!(club.id) == club
    end

    test "create_club/1 with valid data creates a club" do
      valid_attrs = %{founding_date: ~D[2022-10-29], name: "some name", reference_number: "some reference_number", website_url: "some website_url"}

      assert {:ok, %Club{} = club} = Organizations.create_club(valid_attrs)
      assert club.founding_date == ~D[2022-10-29]
      assert club.name == "some name"
      assert club.reference_number == "some reference_number"
      assert club.website_url == "some website_url"
    end

    test "create_club/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_club(@invalid_attrs)
    end

    test "update_club/2 with valid data updates the club" do
      club = club_fixture()
      update_attrs = %{founding_date: ~D[2022-10-30], name: "some updated name", reference_number: "some updated reference_number", website_url: "some updated website_url"}

      assert {:ok, %Club{} = club} = Organizations.update_club(club, update_attrs)
      assert club.founding_date == ~D[2022-10-30]
      assert club.name == "some updated name"
      assert club.reference_number == "some updated reference_number"
      assert club.website_url == "some updated website_url"
    end

    test "update_club/2 with invalid data returns error changeset" do
      club = club_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizations.update_club(club, @invalid_attrs)
      assert club == Organizations.get_club!(club.id)
    end

    test "delete_club/1 deletes the club" do
      club = club_fixture()
      assert {:ok, %Club{}} = Organizations.delete_club(club)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_club!(club.id) end
    end

    test "change_club/1 returns a club changeset" do
      club = club_fixture()
      assert %Ecto.Changeset{} = Organizations.change_club(club)
    end
  end
end
