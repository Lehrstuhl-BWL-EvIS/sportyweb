defmodule Sportyweb.Documents.ContactDocument do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Documents.Document

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_types [
    [key: "Ausweiskopie", value: "id_card"],
    [key: "SEPA-Mandat", value: "sepa_mandate"],
    [key: "Attest / Gesundheitsnachweis", value: "health_certificate"],
    [key: "Nachweis Schüler/Student", value: "student_proof"],
    [key: "Elternerlaubnis", value: "parental_consent"],
    [key: "Datenschutzerklärung", value: "data_privacy_agreement"],
    [key: "Foto-Freigabe", value: "photo_release"],
    [key: "Ermäßigungsnachweis", value: "fee_reduction_proof"],
    [key: "Sonstiges", value: "custom"]
  ]

  schema "contact_documents" do
    field :type, :string

    belongs_to :contact, Contact
    belongs_to :document, Document

    timestamps(type: :utc_datetime)
  end

  def changeset(contact_document, attrs) do
    contact_document
    |> cast(attrs, [:type, :contact_id, :document_id])
    |> validate_required([:type, :contact_id, :document_id])
    |> validate_inclusion(:type, valid_types())
    |> assoc_constraint(:contact)
    |> assoc_constraint(:document)
  end

  def get_valid_types, do: @valid_types
  def valid_types, do: Enum.map(@valid_types, & &1[:value])
end
