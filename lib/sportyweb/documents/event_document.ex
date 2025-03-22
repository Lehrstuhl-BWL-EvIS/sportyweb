defmodule Sportyweb.Documents.EventDocument do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Calendar.Event
  alias Sportyweb.Documents.Document

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @valid_types [
    [key: "Einladung", value: "invitation"],
    [key: "Teilnehmerliste", value: "participant_list"],
    [key: "Sicherheitskonzept", value: "safety_plan"],
    [key: "Ergebnisliste", value: "results"],
    [key: "Abrechnung", value: "billing_statement"],
    [key: "Foto-Freigaben", value: "photo_releases"],
    [key: "Sonstiges", value: "custom"]
  ]

  schema "event_documents" do
    field :type, :string

    belongs_to :event, Event
    belongs_to :document, Document

    timestamps(type: :utc_datetime)
  end

  def changeset(event_document, attrs) do
    event_document
    |> cast(attrs, [:type, :event_id, :document_id])
    |> validate_required([:type, :event_id, :document_id])
    |> validate_inclusion(:type, valid_types())
    |> assoc_constraint(:event)
    |> assoc_constraint(:document)
  end

  def get_valid_types, do: @valid_types
  def valid_types, do: Enum.map(@valid_types, & &1[:value])
end
