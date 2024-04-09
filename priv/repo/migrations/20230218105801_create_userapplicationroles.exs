defmodule Sportyweb.Repo.Migrations.CreateUserapplicationroles do
  use Ecto.Migration

  def change do
    create table(:userapplicationroles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      add :applicationrole_id,
          references(:applicationroles, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps()
    end

    create index(:userapplicationroles, [:user_id])
    create index(:userapplicationroles, [:applicationrole_id])

    create unique_index(:userapplicationroles, [:user_id, :applicationrole_id])
  end
end
