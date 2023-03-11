defmodule Sportyweb.Repo.Migrations.CreateEventNotes do
  use Ecto.Migration

  def change do
    create table(:event_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :delete_all, type: :binary_id), null: false
      add :note_id, references(:notes, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:event_notes, [:event_id])
    create unique_index(:event_notes, [:note_id])
  end
end
