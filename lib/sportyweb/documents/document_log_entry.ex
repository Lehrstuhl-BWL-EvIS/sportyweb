defmodule Sportyweb.Documents.DocumentLogEntry do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Accounts.User
  alias Sportyweb.Documents.Document

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "document_log_entries" do
    field :action, :string
    field :changes, :map, default: %{}
    field :extension_changes, :map, default: %{}
    field :ip_address, :string

    belongs_to :document, Document
    belongs_to :changed_by, User

    timestamps(type: :utc_datetime)
  end

  def changeset(document_log_entry, attrs) do
    document_log_entry
    |> cast(attrs, [:document_id, :changed_by_id, :action, :changes, :extension_changes, :ip_address])
    |> validate_required([:document_id, :action])
    |> assoc_constraint(:document)
    |> assoc_constraint(:changed_by)
  end
end
