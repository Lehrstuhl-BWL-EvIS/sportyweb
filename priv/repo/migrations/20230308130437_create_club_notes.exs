defmodule Sportyweb.Repo.Migrations.CreateClubNotes do
  use Ecto.Migration

  def change do
    create table(:club_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false
      add :note_id, references(:notes, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:club_notes, [:club_id])
    create unique_index(:club_notes, [:note_id])
  end
end
