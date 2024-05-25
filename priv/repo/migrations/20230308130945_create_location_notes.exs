defmodule Sportyweb.Repo.Migrations.CreateLocationNotes do
  use Ecto.Migration

  def change do
    create table(:location_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :location_id, references(:locations, on_delete: :delete_all, type: :binary_id),
        null: false

      add :note_id, references(:notes, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:location_notes, [:location_id])
    create unique_index(:location_notes, [:note_id])
  end
end
