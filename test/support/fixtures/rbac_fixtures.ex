defmodule Sportyweb.RBACFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.RBAC` context.
  """

  @doc """
  Generate a role.
  """
  def role_fixture(attrs \\ %{}) do
    {:ok, role} =
      attrs
      |> Enum.into(%{
        name: "some name",
        roles: ["option1", "option2"]
      })
      |> Sportyweb.RBAC.create_role()

    role
  end
end
