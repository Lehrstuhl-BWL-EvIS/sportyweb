defmodule Sportyweb.Asset.EquipmentNote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "equipment_notes" do

    field :equipment_id, :binary_id
    field :note_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(equipment_note, attrs) do
    equipment_note
    |> cast(attrs, [])
    |> validate_required([])
  end
end
