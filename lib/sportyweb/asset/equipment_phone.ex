defmodule Sportyweb.Asset.EquipmentPhone do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "equipment_phones" do
    belongs_to :equipment, Equipment
    belongs_to :phone, Phone

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(equipment_phone, attrs) do
    equipment_phone
    |> cast(attrs, [:equipment_id, :phone_id])
    |> validate_required([:equipment_id, :phone_id])
    |> unique_constraint(:phone_id, name: "equipment_phones_phone_id_index")
  end
end
