defmodule Sportyweb.Documents.Document do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Sportyweb.Accounts.User
  alias Sportyweb.Organization.Club
  alias Sportyweb.Documents.DocumentLogEntry
  alias Sportyweb.Documents.DocumentComment

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "documents" do
    field :title, :string, default: ""
    field :description, :string, default: ""
    field :filename, :string
    field :content_type, :string
    field :byte_size, :integer, default: 0
    field :storage_path, :string
    field :thumbnail_path, :string, default: nil
    field :checksum, :string
    field :fulltext, :string, default: nil
    field :locked, :boolean, default: false
    field :public, :boolean, default: false
    field :deleted_at, :utc_datetime

    belongs_to :club, Club
    belongs_to :uploaded_by, User
    has_many :document_logs, DocumentLogEntry
    has_many :document_comments, DocumentComment

    # polymorphic extensions
    has_one :contact_document, Sportyweb.Documents.ContactDocument, foreign_key: :document_id
    has_one :club_document, Sportyweb.Documents.ClubDocument, foreign_key: :document_id
    has_one :contract_document, Sportyweb.Documents.ContractDocument, foreign_key: :document_id

    has_one :department_document, Sportyweb.Documents.DepartmentDocument,
      foreign_key: :document_id

    has_one :equipment_document, Sportyweb.Documents.EquipmentDocument, foreign_key: :document_id
    has_one :event_document, Sportyweb.Documents.EventDocument, foreign_key: :document_id
    has_one :group_document, Sportyweb.Documents.GroupDocument, foreign_key: :document_id
    has_one :location_document, Sportyweb.Documents.LocationDocument, foreign_key: :document_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [
      :title,
      :description,
      :filename,
      :content_type,
      :byte_size,
      :storage_path,
      :thumbnail_path,
      :checksum,
      :fulltext,
      :locked,
      :public,
      :club_id,
      :uploaded_by_id
    ])
    |> validate_required([
      :title,
      :description,
      :filename,
      :content_type,
      :byte_size,
      :storage_path,
      :checksum,
      :club_id,
      :uploaded_by_id
    ])
    |> validate_length(:filename, min: 1)
    |> validate_length(:content_type, min: 1)
    |> validate_length(:storage_path, min: 1)
    |> validate_length(:checksum, is: 64)
    |> assoc_constraint(:uploaded_by)
    |> assoc_constraint(:club)
  end

  def for_club_query(%{"q" => term}) when is_binary(term) and term != "" do
    __MODULE__
    |> where_fulltext(term)
    |> strip_fulltext_and_preload()
  end

  def for_club_query(_params) do
    __MODULE__
    |> strip_fulltext_and_preload()
  end

  defp where_fulltext(query, term) do
  tsq =
    term
    |> String.split()
    |> Enum.map(&("#{&1}:*"))
    |> Enum.join(" & ")

  from d in query,
    where: fragment("""
      -- German-Stemming-Index
      to_tsvector('german',
        coalesce(?, '') || ' ' ||
        coalesce(?, '') || ' ' ||
        coalesce(?, '')
      ) @@ to_tsquery('german', ?)
      OR
      -- Simple-Dictionary (kein Stemming, keine Mindestlänge)
      to_tsvector('simple',
        coalesce(?, '') || ' ' ||
        coalesce(?, '') || ' ' ||
        coalesce(?, '')
      ) @@ to_tsquery('simple', ?)
    """,
      # erster Vergleich (german)
      d.title, d.description, d.fulltext, ^tsq,
      # zweiter Vergleich (simple)
      d.title, d.description, d.fulltext, ^tsq
    )
end


  defp strip_fulltext_and_preload(queryable) do
    from d in queryable,
      where: is_nil(d.deleted_at),
      select: struct(d, ^fields_without_fulltext()),
      preload: [
        :uploaded_by,
        :contact_document,
        :club_document,
        :contract_document,
        :department_document,
        :equipment_document,
        :event_document,
        :group_document,
        :location_document
      ]
  end

  @spec with_active_documents(module()) :: Ecto.Query.t()
  def with_active_documents(join_schema) do
    from js in join_schema,
      join: d in assoc(js, :document),
      where: is_nil(d.deleted_at),
      preload: [document: ^preload_without_fulltext()]
  end

  def preload_without_fulltext do
  from d in __MODULE__,
    # 1) Struct mit allen Feldern außer :fulltext
    select: struct(d, ^fields_without_fulltext()),
    # 2) dazu gleich die :uploaded_by-Assoziation vorladen
    preload: [:uploaded_by]
end

  defp fields_without_fulltext do
    __schema__(:fields)
    |> Enum.reject(&(&1 == :fulltext))
  end
end
