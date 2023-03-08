defmodule Sportyweb.Asset.VenueNote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "venue_notes" do

    field :venue_id, :binary_id
    field :note_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(venue_note, attrs) do
    venue_note
    |> cast(attrs, [])
    |> validate_required([])
  end
end
