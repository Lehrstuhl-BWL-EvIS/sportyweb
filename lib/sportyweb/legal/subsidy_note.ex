defmodule Sportyweb.Legal.SubsidyNote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "subsidy_notes" do

    field :subsidy_id, :binary_id
    field :note_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(subsidy_note, attrs) do
    subsidy_note
    |> cast(attrs, [])
    |> validate_required([])
  end
end
