defmodule Sportyweb.Legal.FeeNote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "fee_notes" do

    field :fee_id, :binary_id
    field :note_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(fee_note, attrs) do
    fee_note
    |> cast(attrs, [])
    |> validate_required([])
  end
end
