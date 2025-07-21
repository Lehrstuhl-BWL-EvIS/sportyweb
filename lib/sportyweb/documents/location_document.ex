defmodule Sportyweb.Documents.LocationDocument do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Location
  alias Sportyweb.Documents.Document

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_types [
    [key: "Mietvertrag", value: "rental_contract"],
    [key: "Nutzungsvereinbarung", value: "usage_agreement"],
    [key: "Brandschutzprotokoll", value: "fire_safety_report"],
    [key: "Belegungsplan", value: "occupancy_plan"],
    [key: "Zugangsberechtigung", value: "access_permission"],
    [key: "Sonstiges", value: "custom"]
  ]

  schema "location_documents" do
    field :type, :string

    belongs_to :location, Location
    belongs_to :document, Document

    timestamps(type: :utc_datetime)
  end

  def changeset(location_document, attrs) do
    location_document
    |> cast(attrs, [:type, :location_id, :document_id])
    |> validate_required([:type, :location_id, :document_id])
    |> validate_inclusion(:type, valid_types())
    |> assoc_constraint(:location)
    |> assoc_constraint(:document)
  end

  def get_valid_types, do: @valid_types
  def valid_types, do: Enum.map(@valid_types, & &1[:value])
end
