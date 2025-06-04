defmodule Sportyweb.Repo.Migrations.CreateDocumentLogEntries do
  use Ecto.Migration

  def change do
    create table(:document_log_entries, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :action, :string, null: false
      add :changes, :map, default: %{}, null: false
      add :extension_changes, :map, default: %{}, null: false

      add :document_id, references(:documents, type: :binary_id, on_delete: :delete_all),
        null: false

      add :changed_by_id, references(:users, type: :binary_id, on_delete: :nothing),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:document_log_entries, [:document_id])
    create index(:document_log_entries, [:changed_by_id])
  end
end
