defmodule Sportyweb.Repo.Migrations.CreateVenueNotes do
  use Ecto.Migration

  def change do
    create table(:venue_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :venue_id, references(:venues, on_delete: :delete_all, type: :binary_id), null: false
      add :note_id, references(:notes, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:venue_notes, [:venue_id])
    create unique_index(:venue_notes, [:note_id])
  end
end
