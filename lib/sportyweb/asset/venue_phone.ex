defmodule Sportyweb.Asset.VenuePhone do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "venue_phones" do

    field :venue_id, :binary_id
    field :phone_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(venue_phone, attrs) do
    venue_phone
    |> cast(attrs, [])
    |> validate_required([])
  end
end
