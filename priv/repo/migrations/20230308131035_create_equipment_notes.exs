defmodule Sportyweb.Repo.Migrations.CreateEquipmentNotes do
  use Ecto.Migration

  def change do
    create table(:equipment_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :equipment_id, references(:equipment, on_delete: :nothing, type: :binary_id)
      add :note_id, references(:notes, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:equipment_notes, [:equipment_id])
    create index(:equipment_notes, [:note_id])
  end
end
