defmodule Sportyweb.Calendar.EventEquipment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_equipment" do

    field :event_id, :binary_id
    field :equipment_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(event_equipment, attrs) do
    event_equipment
    |> cast(attrs, [])
    |> validate_required([])
  end
end
