defmodule Sportyweb.Organization.ClubNote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "club_notes" do

    field :club_id, :binary_id
    field :note_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(club_note, attrs) do
    club_note
    |> cast(attrs, [])
    |> validate_required([])
  end
end
