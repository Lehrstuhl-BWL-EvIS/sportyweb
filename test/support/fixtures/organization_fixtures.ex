defmodule Sportyweb.OrganizationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Organization` context.
  """

  @doc """
  Generate a unique club website_url.
  """
  def unique_club_website_url, do: "https://www.website_url_#{System.unique_integer([:positive])}.com"

  @doc """
  Generate a club.
  """
  def club_fixture(attrs \\ %{}) do
    {:ok, club} =
      attrs
      |> Enum.into(%{
        name: "some name",
        reference_number: "some reference_number",
        description: "some description",
        website_url: unique_club_website_url(),
        founded_at: ~D[2022-11-05]
      })
      |> Sportyweb.Organization.create_club()

    club
  end

  @doc """
  Generate a department.
  """
  def department_fixture(attrs \\ %{}) do
    club = club_fixture()

    {:ok, department} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        name: "some name",
        reference_number: "some reference_number",
        description: "some description",
        created_at: ~D[2022-11-05]
      })
      |> Sportyweb.Organization.create_department()

    department
  end

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    department = department_fixture()

    {:ok, group} =
      attrs
      |> Enum.into(%{
        department_id: department.id,
        name: "some name",
        reference_number: "some reference_number",
        description: "some description",
        created_at: ~D[2022-11-05]
      })
      |> Sportyweb.Organization.create_group()

    group
  end
end
