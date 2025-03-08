defmodule Sportyweb.Polymorphic.Document do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Accounts.User

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

    belongs_to :uploaded_by, User

    timestamps(type: :utc_datetime)
  end


  @doc false
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
        :uploaded_by_id
      ])
      |> validate_length(:filename, min: 1)
      |> validate_length(:content_type, min: 1)
      |> validate_length(:storage_path, min: 1)
      |> validate_length(:checksum, is: 64) # z. B. für SHA-256
      |> assoc_constraint(:uploaded_by)
    end
end
