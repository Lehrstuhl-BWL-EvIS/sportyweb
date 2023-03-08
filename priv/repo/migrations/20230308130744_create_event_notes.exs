defmodule Sportyweb.Repo.Migrations.CreateEventNotes do
  use Ecto.Migration

  def change do
    create table(:event_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :nothing, type: :binary_id)
      add :note_id, references(:notes, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:event_notes, [:event_id])
    create index(:event_notes, [:note_id])
  end
end
