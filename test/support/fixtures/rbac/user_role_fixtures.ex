defmodule Sportyweb.RBAC.UserRoleFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.RBAC.UserRole` context.
  """

  @doc """
  Generate a user_club_role.
  """
  def user_club_role_fixture(attrs \\ %{}) do
    {:ok, user_club_role} =
      attrs
      |> Enum.into(%{

      })
      |> Sportyweb.RBAC.UserRole.create_user_club_role()

    user_club_role
  end
end
