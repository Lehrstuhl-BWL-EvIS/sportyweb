defmodule Sportyweb.Organization.GroupNote do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Group
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "group_notes" do
    belongs_to :group, Group
    belongs_to :note, Note

    timestamps()
  end

  @doc false
  def changeset(group_note, attrs) do
    group_note
    |> cast(attrs, [:group_id, :note_id])
    |> validate_required([:group_id, :note_id])
    |> unique_constraint(:note_id, name: "group_notes_note_id_index")
  end
end
