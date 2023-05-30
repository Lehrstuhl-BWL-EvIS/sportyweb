defmodule Sportyweb.Repo.Migrations.CreateSubsidyNotes do
  use Ecto.Migration

  def change do
    create table(:subsidy_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :subsidy_id, references(:subsidies, on_delete: :nothing, type: :binary_id)
      add :note_id, references(:notes, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:subsidy_notes, [:subsidy_id])
    create index(:subsidy_notes, [:note_id])
  end
end
