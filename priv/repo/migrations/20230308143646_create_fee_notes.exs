defmodule Sportyweb.Repo.Migrations.CreateFeeNotes do
  use Ecto.Migration

  def change do
    create table(:fee_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :fee_id, references(:fees, on_delete: :nothing, type: :binary_id)
      add :note_id, references(:notes, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:fee_notes, [:fee_id])
    create index(:fee_notes, [:note_id])
  end
end
