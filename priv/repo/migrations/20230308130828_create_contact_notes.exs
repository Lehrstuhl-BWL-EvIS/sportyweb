defmodule Sportyweb.Repo.Migrations.CreateContactNotes do
  use Ecto.Migration

  def change do
    create table(:contact_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :contact_id, references(:contacts, on_delete: :nothing, type: :binary_id)
      add :note_id, references(:notes, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:contact_notes, [:contact_id])
    create index(:contact_notes, [:note_id])
  end
end
