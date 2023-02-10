defmodule Sportyweb.RBAC.RoleFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.RBAC.Role` context.
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
      |> Sportyweb.RBAC.Role.create_club_role()

    club_role
  end
end
