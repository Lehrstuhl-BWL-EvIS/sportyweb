defmodule Sportyweb.Repo.Migrations.CreateFeeNotes do
  use Ecto.Migration

  def change do
    create table(:fee_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :fee_id, references(:fees, on_delete: :delete_all, type: :binary_id), null: false
      add :note_id, references(:notes, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:fee_notes, [:fee_id])
    create unique_index(:fee_notes, [:note_id])
  end
end
