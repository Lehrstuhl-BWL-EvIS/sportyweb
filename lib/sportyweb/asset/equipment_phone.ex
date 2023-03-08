defmodule Sportyweb.Asset.EquipmentPhone do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "equipment_phones" do

    field :equipment_id, :binary_id
    field :phone_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(equipment_phone, attrs) do
    equipment_phone
    |> cast(attrs, [])
    |> validate_required([])
  end
end
