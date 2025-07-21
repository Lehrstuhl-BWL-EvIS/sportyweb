defmodule Sportyweb.Documents.DocumentComment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Accounts.User
  alias Sportyweb.Documents.Document

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "document_comments" do
    field :comment, :string

    belongs_to :document, Document
    belongs_to :commented_by, User

    timestamps(type: :utc_datetime)
  end

  def changeset(document_comment, attrs) do
    document_comment
    |> cast(attrs, [:document_id, :commented_by_id, :comment])
    |> validate_required([:document_id, :commented_by_id, :comment])
    |> assoc_constraint(:document)
    |> assoc_constraint(:commented_by)
  end
end
