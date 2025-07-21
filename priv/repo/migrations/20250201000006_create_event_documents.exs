defmodule Sportyweb.Repo.Migrations.CreateEventDocuments do
  use Ecto.Migration

  def change do
    create table(:event_documents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false

      add :event_id, references(:events, type: :binary_id, on_delete: :delete_all), null: false
      add :document_id, references(:documents, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:event_documents, [:event_id])
    create index(:event_documents, [:document_id])
    create index(:event_documents, [:type])
  end
end
