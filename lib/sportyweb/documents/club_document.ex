defmodule Sportyweb.Documents.ClubDocument do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Documents.Document

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_types [
    [key: "Satzung", value: "statutes"],
    [key: "Versicherungsnachweis", value: "insurance_proof"],
    [key: "Gründungsurkunde", value: "founding_document"],
    [key: "Finanzbericht", value: "financial_report"],
    [key: "Datenschutzkonzept", value: "data_protection_policy"],
    [key: "Förderantrag", value: "funding_application"],
    [key: "Sonstiges", value: "custom"]
  ]

  schema "club_documents" do
    field :type, :string

    belongs_to :club, Club
    belongs_to :document, Document

    timestamps(type: :utc_datetime)
  end

  def changeset(club_document, attrs) do
    club_document
    |> cast(attrs, [:type, :club_id, :document_id])
    |> validate_required([:type, :club_id, :document_id])
    |> validate_inclusion(:type, valid_types())
    |> assoc_constraint(:club)
    |> assoc_constraint(:document)
  end

  def get_valid_types, do: @valid_types
  def valid_types, do: Enum.map(@valid_types, & &1[:value])
end
