defmodule Sportyweb.Asset.VenuePhone do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Venue
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "venue_phones" do
    belongs_to :venue, Venue
    belongs_to :phone, Phone

    timestamps()
  end

  @doc false
  def changeset(venue_phone, attrs) do
    venue_phone
    |> cast(attrs, [:venue_id, :phone_id])
    |> validate_required([:venue_id, :phone_id])
    |> unique_constraint(:phone_id, name: "venue_phones_phone_id_index")
  end
end
