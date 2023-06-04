defmodule Sportyweb.Asset.Equipment do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Asset.EquipmentEmail
  alias Sportyweb.Asset.EquipmentFee
  alias Sportyweb.Asset.EquipmentNote
  alias Sportyweb.Asset.EquipmentPhone
  alias Sportyweb.Asset.Venue
  alias Sportyweb.Finance.Fee
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "equipment" do
    belongs_to :venue, Venue
    many_to_many :emails, Email, join_through: EquipmentEmail
    many_to_many :fees, Fee, join_through: EquipmentFee
    many_to_many :notes, Note, join_through: EquipmentNote
    many_to_many :phones, Phone, join_through: EquipmentPhone

    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :serial_number, :string, default: ""
    field :description, :string, default: ""
    field :purchase_date, :date, default: nil
    field :commission_date, :date, default: nil
    field :decommission_date, :date, default: nil

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
      :purchase_date,
      :commission_date,
      :decommission_date],
      empty_values: ["", nil]
    )
    |> cast_assoc(:emails, required: true)
    |> cast_assoc(:notes, required: true)
    |> cast_assoc(:phones, required: true)
    |> validate_required([:venue_id, :name])
    |> update_change(:name, &String.trim/1)
    |> update_change(:reference_number, &String.trim/1)
    |> update_change(:serial_number, &String.trim/1)
    |> update_change(:description, &String.trim/1)
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:serial_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> validate_dates_order(:purchase_date, :commission_date,
      "Muss zeitlich später als oder gleich \"Gekauft am\" sein!")
    |> validate_dates_order(:commission_date, :decommission_date,
      "Muss zeitlich später als oder gleich \"Nutzung ab\" sein!")
  end
end
