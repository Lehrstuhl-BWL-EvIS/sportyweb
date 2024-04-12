defmodule Sportyweb.Repo.Migrations.CreateUserdepartmentroles do
  use Ecto.Migration

  def change do
    create table(:userdepartmentroles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      add :department_id, references(:departments, on_delete: :delete_all, type: :binary_id),
        null: false

      add :departmentrole_id,
          references(:departmentroles, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps()
    end

    create index(:userdepartmentroles, [:user_id])
    create index(:userdepartmentroles, [:department_id])
    create index(:userdepartmentroles, [:departmentrole_id])

    create unique_index(:userdepartmentroles, [:user_id, :department_id, :departmentrole_id])
  end
end
