defmodule Sportyweb.Organization.ClubNote do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "club_notes" do
    belongs_to :club, Club
    belongs_to :note, Note

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(club_note, attrs) do
    club_note
    |> cast(attrs, [:club_id, :note_id])
    |> validate_required([:club_id, :note_id])
    |> unique_constraint(:note_id, name: "club_notes_note_id_index")
  end
end
