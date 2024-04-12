defmodule Sportyweb.Asset.VenuePostalAddress do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Venue
  alias Sportyweb.Polymorphic.PostalAddress

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "venue_postal_addresses" do
    belongs_to :venue, Venue
    belongs_to :postal_address, PostalAddress

    timestamps()
  end

  @doc false
  def changeset(venue_postal_address, attrs) do
    venue_postal_address
    |> cast(attrs, [:venue_id, :postal_address_id])
    |> validate_required([:venue_id, :postal_address_id])
    |> unique_constraint(:postal_address_id,
      name: "venue_postal_addresses_postal_address_id_index"
    )
  end
end
