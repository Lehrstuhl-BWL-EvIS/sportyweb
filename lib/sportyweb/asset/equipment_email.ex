defmodule Sportyweb.Asset.EquipmentEmail do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "equipment_emails" do

    field :equipment_id, :binary_id
    field :email_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(equipment_email, attrs) do
    equipment_email
    |> cast(attrs, [])
    |> validate_required([])
  end
end
