defmodule Sportyweb.Asset.Equipment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Venue

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "equipment" do
    belongs_to :venue, Venue

    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :serial_number, :string, default: ""
    field :description, :string, default: ""
    field :purchased_at, :date, default: nil
    field :commission_at, :date, default: nil
    field :decommission_at, :date, default: nil

    timestamps()
  end

  @doc false
  def changeset(equipment, attrs) do
    equipment
    |> cast(attrs, [
      :venue_id,
      :name,
      :reference_number,
      :serial_number,
      :description,
      :purchased_at,
      :commission_at,
      :decommission_at
      ], empty_values: ["", nil])
    |> validate_required([:venue_id, :name])
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:serial_number, max: 250)
    |> validate_length(:description, max: 20_000)
  end
end
