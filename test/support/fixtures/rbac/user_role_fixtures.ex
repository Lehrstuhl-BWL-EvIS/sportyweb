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
      attrs |> Sportyweb.RBAC.UserRole.create_user_club_role()

    user_club_role
  end

  @doc """
  Generate a user_application_role.
  """
  def user_application_role_fixture(attrs \\ %{}) do
    {:ok, user_application_role} =
      attrs |> Sportyweb.RBAC.UserRole.create_user_application_role()

    user_application_role
  end
end
