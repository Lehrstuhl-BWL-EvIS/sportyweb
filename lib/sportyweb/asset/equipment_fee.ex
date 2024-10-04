defmodule Sportyweb.Asset.EquipmentFee do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Finance.Fee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "equipment_fees" do
    belongs_to :equipment, Equipment
    belongs_to :fee, Fee

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(equipment_fee, attrs) do
    equipment_fee
    |> cast(attrs, [:equipment_id, :fee_id])
    |> validate_required([:equipment_id, :fee_id])
    |> unique_constraint(:fee_id, name: "equipment_fees_fee_id_index")
  end
end
