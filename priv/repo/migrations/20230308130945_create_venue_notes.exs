defmodule Sportyweb.Repo.Migrations.CreateVenueNotes do
  use Ecto.Migration

  def change do
    create table(:venue_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :venue_id, references(:venues, on_delete: :nothing, type: :binary_id)
      add :note_id, references(:notes, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:venue_notes, [:venue_id])
    create index(:venue_notes, [:note_id])
  end
end
