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
  Generate a user_club_roles.
  """
  def user_club_roles_fixture(attrs \\ %{}) do
    {:ok, user_club_roles} =
      attrs
      |> Enum.into(%{

      })
      |> Sportyweb.AccessControl.create_user_club_roles()

    user_club_roles
  end
end
