defmodule Sportyweb.PolymorphicFixtures do
  @moduledoc """
  This module defines test helpers for creating
  attrs/params that can be used by other fixtures to create polymorphic associations.

  https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html
  """

  @doc """
  Return attrs/params for an email.
  """
  def email_attrs(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      type: "other",
      address: "someone@example.com"
    })
  end

  @doc """
  Return attrs/params for financial_data.
  """
  def financial_data_attrs(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      type: "direct_debit",
      direct_debit_account_holder: "some name",
      direct_debit_iban: "DE06495352657836424132",
      direct_debit_institute: "some bank"
    })
  end

  @doc """
  Return attrs/params for an internal_event.
  """
  def internal_event_attrs(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      commission_date: ~D[2023-02-24],
      archive_date: nil,
      is_recurring: true,
      frequency: "year",
      interval: 1,
    })
  end

  @doc """
  Return attrs/params for a note.
  """
  def note_attrs(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      content: "some content"
    })
  end

  @doc """
  Return attrs/params for a phone.
  """
  def phone_attrs(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      type: "other",
      number: "012345 678910"
    })
  end

  @doc """
  Return attrs/params for a postal_address.
  """
  def postal_address_attrs(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      street: "Universitätsstraße",
      street_number: "11",
      street_additional_information: "",
      zipcode: "58097",
      city: "Hagen",
      country: "DEU"
    })
  end
end
