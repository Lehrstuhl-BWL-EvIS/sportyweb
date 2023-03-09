defmodule Sportyweb.Asset.VenueNote do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Venue
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "venue_notes" do
    belongs_to :venue, Venue
    belongs_to :note, Note

    timestamps()
  end

  @doc false
  def changeset(venue_note, attrs) do
    venue_note
    |> cast(attrs, [:venue_id, :note_id])
    |> validate_required([:venue_id, :note_id])
    |> unique_constraint(:note_id, name: "venue_notes_note_id_index")
  end
end
