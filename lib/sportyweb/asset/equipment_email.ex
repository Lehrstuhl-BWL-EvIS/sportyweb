defmodule Sportyweb.Asset.EquipmentEmail do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Polymorphic.Email

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "equipment_emails" do
    belongs_to :equipment, Equipment
    belongs_to :email, Email

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(equipment_email, attrs) do
    equipment_email
    |> cast(attrs, [:equipment_id, :email_id])
    |> validate_required([:equipment_id, :email_id])
    |> unique_constraint(:email_id, name: "equipment_emails_email_id_index")
  end
end
