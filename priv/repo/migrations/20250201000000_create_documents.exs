defmodule Sportyweb.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false, default: ""
      add :description, :text, null: false, default: ""
      add :filename, :string, null: false
      add :content_type, :string, null: false
      add :byte_size, :integer, null: false
      add :storage_path, :string, null: false
      add :thumbnail_path, :string, null: true
      add :checksum, :string, null: false
      add :uploaded_by_id, references(:users, type: :binary_id, on_delete: :nothing), null: false
      timestamps(type: :utc_datetime)
    end
  end
end
