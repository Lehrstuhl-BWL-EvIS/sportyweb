defmodule Sportyweb.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
  def role_super_user, do: ["super_user"]

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def valid_user_attributes_super_user(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      roles: role_super_user()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Sportyweb.Accounts.register_user()

    user
  end

  def user_fixture_customer(attrs \\ %{}), do: user_fixture(attrs)
  def user_fixture_super_user(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes_super_user()
      |> Sportyweb.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
