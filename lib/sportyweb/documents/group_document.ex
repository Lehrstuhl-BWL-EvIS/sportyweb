defmodule Sportyweb.Documents.GroupDocument do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Group
  alias Sportyweb.Documents.Document

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_types [
    [key: "Spielplan", value: "schedule"],
    [key: "Teilnehmerliste", value: "participant_list"],
    [key: "Trainervertrag", value: "coach_contract"],
    [key: "Foto-Freigaben", value: "photo_releases"],
    [key: "Wettkampfergebnisse", value: "competition_results"],
    [key: "Sonstiges", value: "custom"]
  ]

  schema "group_documents" do
    field :type, :string

    belongs_to :group, Group
    belongs_to :document, Document

    timestamps(type: :utc_datetime)
  end

  def changeset(group_document, attrs) do
    group_document
    |> cast(attrs, [:type, :group_id, :document_id])
    |> validate_required([:type, :group_id, :document_id])
    |> validate_inclusion(:type, valid_types())
    |> assoc_constraint(:group)
    |> assoc_constraint(:document)
  end

  def get_valid_types, do: @valid_types
  def valid_types, do: Enum.map(@valid_types, & &1[:value])
end
