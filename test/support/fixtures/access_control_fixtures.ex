defmodule Sportyweb.AccessControlFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.AccessControl` context.
  """

  @doc """
  Generate a club_role.
  """
  def club_role_fixture(attrs \\ %{}) do
    {:ok, club_role} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Sportyweb.AccessControl.create_club_role()

    club_role
  end

  @doc """
  Generate a user_club_role.
  """
  def user_club_role_fixture(attrs \\ %{}) do
    {:ok, user_club_role} =
      attrs
      |> Enum.into(%{

      })
      |> Sportyweb.AccessControl.create_user_club_role()

    user_club_role
  end

  @doc """
  Generate a application_role.
  """
  def application_role_fixture(attrs \\ %{}) do
    {:ok, application_role} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Sportyweb.AccessControl.create_application_role()

    application_role
  end

  @doc """
  Generate a user_application_role.
  """
  def user_application_role_fixture(attrs \\ %{}) do
    {:ok, user_application_role} =
      attrs
      |> Enum.into(%{

      })
      |> Sportyweb.AccessControl.create_user_application_role()

    user_application_role
  end
end
