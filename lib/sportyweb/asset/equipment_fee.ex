defmodule Sportyweb.Asset.EquipmentFee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Legal.Fee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "equipment_fees" do
    belongs_to :equipment, Equipment
    belongs_to :fee, Fee

    timestamps()
  end

  @doc false
  def changeset(equipment_fee, attrs) do
    equipment_fee
    |> cast(attrs, [:equipment_id, :fee_id])
    |> validate_required([:equipment_id, :fee_id])
    |> unique_constraint(:club_id, name: "equipment_fees_equipment_id_fee_id_index")
  end
end
