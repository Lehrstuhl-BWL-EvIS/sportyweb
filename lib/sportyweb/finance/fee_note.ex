defmodule Sportyweb.Finance.FeeNote do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Finance.Fee
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "fee_notes" do
    belongs_to :fee, Fee
    belongs_to :note, Note

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(fee_note, attrs) do
    fee_note
    |> cast(attrs, [:fee_id, :note_id])
    |> validate_required([:fee_id, :note_id])
    |> unique_constraint(:note_id, name: "fee_notes_note_id_index")
  end
end
