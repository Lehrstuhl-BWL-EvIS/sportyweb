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

  @doc """
  Generate a application_role.
  """
  def application_role_fixture(attrs \\ %{}) do
    {:ok, application_role} =
      attrs
      |> Enum.into(%{
        name: "Tester"
      })
      |> Sportyweb.RBAC.Role.create_application_role()

    application_role
  end

  @doc """
  Generate a department_role.
  """
  def department_role_fixture(attrs \\ %{}) do
    {:ok, department_role} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Sportyweb.RBAC.Role.create_department_role()

    department_role
  end
end
