defmodule Sportyweb.Repo.Migrations.CreateContactNotes do
  use Ecto.Migration

  def change do
    create table(:contact_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id), null: false
      add :note_id, references(:notes, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:contact_notes, [:contact_id])
    create unique_index(:contact_notes, [:note_id])
  end
end
