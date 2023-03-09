defmodule Sportyweb.Calendar.EventEquipment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Calendar.Event

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_equipment" do
    belongs_to :event, Event
    belongs_to :equipment, Equipment

    timestamps()
  end

  @doc false
  def changeset(event_equipment, attrs) do
    event_equipment
    |> cast(attrs, [:event_id, :equipment_id])
    |> validate_required([:event_id, :equipment_id])
    |> unique_constraint(:equipment_id, name: "event_equipment_equipment_id_index")
  end
end
