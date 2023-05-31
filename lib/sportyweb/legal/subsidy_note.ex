defmodule Sportyweb.Legal.SubsidyNote do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.Subsidy
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "subsidy_notes" do
    belongs_to :subsidy, Subsidy
    belongs_to :note, Note

    timestamps()
  end

  @doc false
  def changeset(subsidy_note, attrs) do
    subsidy_note
    |> cast(attrs, [:subsidy_id, :note_id])
    |> validate_required([:subsidy_id, :note_id])
    |> unique_constraint(:note_id, name: "subsidy_notes_note_id_index")
  end
end
