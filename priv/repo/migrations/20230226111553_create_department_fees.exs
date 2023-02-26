defmodule Sportyweb.Repo.Migrations.CreateDepartmentFees do
  use Ecto.Migration

  def change do
    create table(:department_fees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :department_id, references(:departments, on_delete: :nothing, type: :binary_id)
      add :fee_id, references(:fees, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:department_fees, [:department_id])
    create index(:department_fees, [:fee_id])
  end
end
