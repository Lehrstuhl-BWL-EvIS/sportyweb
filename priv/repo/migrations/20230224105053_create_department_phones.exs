defmodule Sportyweb.Repo.Migrations.CreateDepartmentPhones do
  use Ecto.Migration

  def change do
    create table(:department_phones, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :department_id, references(:departments, on_delete: :delete_all, type: :binary_id),
        null: false

      add :phone_id, references(:phones, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:department_phones, [:department_id])
    create unique_index(:department_phones, [:phone_id])
  end
end
