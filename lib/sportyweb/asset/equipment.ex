defmodule Sportyweb.Asset.Equipment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "equipment" do
    field :commission_at, :date
    field :decommission_at, :date
    field :description, :string
    field :name, :string
    field :purchased_at, :date
    field :reference_number, :string
    field :serial_number, :string
    field :venue_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(equipment, attrs) do
    equipment
    |> cast(attrs, [:name, :reference_number, :serial_number, :description, :purchased_at, :commission_at, :decommission_at])
    |> validate_required([:name, :reference_number, :serial_number, :description, :purchased_at, :commission_at, :decommission_at])
  end
end
