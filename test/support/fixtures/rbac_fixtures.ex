defmodule Sportyweb.RBACFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.RBAC` context.
  """

  @doc """
  Generate a role.
  """
  def role_fixture() do
    %Sportyweb.RBAC.Role{
      id: 1,
      name: "some@name.com",
      clubroles: "some role",
      departmentroles: "some role"
    }
  end

  def role_fixture(attrs) do
    %Sportyweb.RBAC.Role{
      id: attrs.id,
      name: attrs.name,
      clubroles: attrs.clubroles,
      departmentroles: attrs.departmentroles
    }
  end
end
