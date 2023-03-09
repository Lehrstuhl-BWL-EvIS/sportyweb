defmodule Sportyweb.Repo.Migrations.CreateEventDepartments do
  use Ecto.Migration

  def change do
    create table(:event_departments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :nothing, type: :binary_id)
      add :department_id, references(:departments, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:event_departments, [:event_id])
    create index(:event_departments, [:department_id])
  end
end
