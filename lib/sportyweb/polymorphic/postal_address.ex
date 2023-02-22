defmodule Sportyweb.Polymorphic.PostalAddress do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "postal_addresses" do
    field :city, :string
    field :country, :string
    field :is_main, :boolean, default: false
    field :street, :string
    field :street_additional_information, :string
    field :street_number, :string
    field :zipcode, :string

    timestamps()
  end

  @doc false
  def changeset(postal_address, attrs) do
    postal_address
    |> cast(attrs, [:street, :street_number, :street_additional_information, :zipcode, :city, :country, :is_main])
    |> validate_required([:street, :street_number, :street_additional_information, :zipcode, :city, :country, :is_main])
  end
end
