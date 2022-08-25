defmodule Sportyweb.MembershipFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Membership` context.
  """

  @doc """
  Generate a member.
  """
  def member_fixture(attrs \\ %{}) do
    {:ok, member} =
      attrs
      |> Enum.into(%{
        date_of_birth: ~D[2022-08-24],
        email1: "some email1",
        email2: "some email2",
        firstname: "some firstname",
        gender: "some gender",
        is_active: true,
        lastname: "some lastname",
        phone1: "some phone1",
        phone2: "some phone2"
      })
      |> Sportyweb.Membership.create_member()

    member
  end
end
