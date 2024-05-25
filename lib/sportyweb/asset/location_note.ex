defmodule Sportyweb.Asset.LocationNote do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Location
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "location_notes" do
    belongs_to :location, Location
    belongs_to :note, Note

    timestamps()
  end

  @doc false
  def changeset(location_note, attrs) do
    location_note
    |> cast(attrs, [:location_id, :note_id])
    |> validate_required([:location_id, :note_id])
    |> unique_constraint(:note_id, name: "location_notes_note_id_index")
  end
end
