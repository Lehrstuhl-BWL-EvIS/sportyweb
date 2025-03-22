defmodule Sportyweb.Documents.DepartmentDocument do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Department
  alias Sportyweb.Documents.Document

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_types [
    [key: "Abteilungsordnung", value: "department_rules"],
    [key: "Finanzplan", value: "financial_plan"],
    [key: "Protokoll Abteilungsversammlung", value: "meeting_minutes"],
    [key: "Förderantrag", value: "funding_application"],
    [key: "Sonstiges", value: "custom"]
  ]

  schema "department_documents" do
    field :type, :string

    belongs_to :department, Department
    belongs_to :document, Document

    timestamps(type: :utc_datetime)
  end

  def changeset(department_document, attrs) do
    department_document
    |> cast(attrs, [:type, :department_id, :document_id])
    |> validate_required([:type, :department_id, :document_id])
    |> validate_inclusion(:type, valid_types())
    |> assoc_constraint(:department)
    |> assoc_constraint(:document)
  end

  def get_valid_types, do: @valid_types
  def valid_types, do: Enum.map(@valid_types, & &1[:value])
end
