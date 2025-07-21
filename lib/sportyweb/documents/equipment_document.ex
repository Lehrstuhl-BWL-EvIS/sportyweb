defmodule Sportyweb.Documents.EquipmentDocument do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Documents.Document

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_types [
    [key: "Rechnung", value: "invoice"],
    [key: "Garantienachweis", value: "warranty_certificate"],
    [key: "Bedienungsanleitung", value: "manual"],
    [key: "Übergabeprotokoll", value: "handover_protocol"],
    [key: "Wartungsnachweis", value: "maintenance_record"],
    [key: "Sonstiges", value: "custom"]
  ]

  schema "equipment_documents" do
    field :type, :string

    belongs_to :equipment, Equipment
    belongs_to :document, Document

    timestamps(type: :utc_datetime)
  end

  def changeset(equipment_document, attrs) do
    equipment_document
    |> cast(attrs, [:type, :equipment_id, :document_id])
    |> validate_required([:type, :equipment_id, :document_id])
    |> validate_inclusion(:type, valid_types())
    |> assoc_constraint(:equipment)
    |> assoc_constraint(:document)
  end

  def get_valid_types, do: @valid_types
  def valid_types, do: Enum.map(@valid_types, & &1[:value])
end
