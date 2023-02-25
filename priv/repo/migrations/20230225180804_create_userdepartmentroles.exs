defmodule Sportyweb.Repo.Migrations.CreateUserdepartmentroles do
  use Ecto.Migration

  def change do
    create table(:userdepartmentroles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :department_id, references(:departments, on_delete: :nothing, type: :binary_id)
      add :departmentrole_id, references(:departmentroles, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:userdepartmentroles, [:user_id])
    create index(:userdepartmentroles, [:department_id])
    create index(:userdepartmentroles, [:departmentrole_id])
  end
end
