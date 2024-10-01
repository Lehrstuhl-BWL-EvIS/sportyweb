defmodule Sportyweb.Repo.Migrations.CreateDepartmentContracts do
  use Ecto.Migration

  def change do
    create table(:department_contracts, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :department_id, references(:departments, on_delete: :delete_all, type: :binary_id),
        null: false

      add :contract_id, references(:contracts, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:department_contracts, [:department_id])
    create index(:department_contracts, [:contract_id])
  end
end
