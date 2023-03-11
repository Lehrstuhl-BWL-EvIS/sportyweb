defmodule Sportyweb.Repo.Migrations.CreateEventDepartments do
  use Ecto.Migration

  def change do
    create table(:event_departments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :delete_all, type: :binary_id), null: false
      add :department_id, references(:departments, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:event_departments, [:event_id])
    create unique_index(:event_departments, [:department_id])
  end
end
