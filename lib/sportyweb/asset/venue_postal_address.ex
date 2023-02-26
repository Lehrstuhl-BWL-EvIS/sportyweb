defmodule Sportyweb.Asset.VenuePostalAddress do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "venue_postal_addresses" do

    field :venue_id, :binary_id
    field :postal_address_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(venue_postal_address, attrs) do
    venue_postal_address
    |> cast(attrs, [])
    |> validate_required([])
  end
end
