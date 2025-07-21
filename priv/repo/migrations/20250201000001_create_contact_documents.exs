defmodule Sportyweb.Repo.Migrations.CreateContactDocuments do
  use Ecto.Migration

  def change do
    create table(:contact_documents, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :type, :string, null: false

      add :contact_id, references(:contacts, type: :binary_id, on_delete: :delete_all), null: false
      add :document_id, references(:documents, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:contact_documents, [:contact_id])
    create index(:contact_documents, [:document_id])
  end
end
