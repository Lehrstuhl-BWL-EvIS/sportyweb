defmodule Sportyweb.Asset.EquipmentNote do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "equipment_notes" do
    belongs_to :equipment, Equipment
    belongs_to :note, Note

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(equipment_note, attrs) do
    equipment_note
    |> cast(attrs, [:equipment_id, :note_id])
    |> validate_required([:equipment_id, :note_id])
    |> unique_constraint(:note_id, name: "equipment_notes_note_id_index")
  end
end
