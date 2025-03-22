defmodule Sportyweb.Documents.ContractDocument do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Documents.Document

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_types [
    [key: "Mitgliedsantrag", value: "membership_application"],
    [key: "Vertragsdokument", value: "contract_document"],
    [key: "Zahlungsvereinbarung", value: "payment_agreement"],
    [key: "Kündigung", value: "termination_letter"],
    [key: "SEPA-Mandat", value: "sepa_mandate"],
    [key: "Ermäßigungsnachweis", value: "fee_reduction_proof"],
    [key: "Sonstiges", value: "custom"]
  ]

  schema "contract_documents" do
    field :type, :string

    belongs_to :contract, Contract
    belongs_to :document, Document

    timestamps(type: :utc_datetime)
  end

  def changeset(contract_document, attrs) do
    contract_document
    |> cast(attrs, [:type, :contract_id, :document_id])
    |> validate_required([:type, :contract_id, :document_id])
    |> validate_inclusion(:type, valid_types())
    |> assoc_constraint(:contract)
    |> assoc_constraint(:document)
  end

  def get_valid_types, do: @valid_types
  def valid_types, do: Enum.map(@valid_types, & &1[:value])
end
