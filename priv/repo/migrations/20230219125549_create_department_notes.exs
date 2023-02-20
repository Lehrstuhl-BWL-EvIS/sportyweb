defmodule Sportyweb.Repo.Migrations.CreateDepartmentNotes do
  use Ecto.Migration

  def change do
    create table(:department_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :department_id, references(:departments, on_delete: :delete_all, type: :binary_id), null: false, default: nil
      add :note_id, references(:notes, on_delete: :delete_all, type: :binary_id), null: false, default: nil

      timestamps()
    end

    create index(:department_notes, [:department_id])
    create index(:department_notes, [:note_id])
    create unique_index(:department_notes, [:department_id, :note_id])
  end
end
