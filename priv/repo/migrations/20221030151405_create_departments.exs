defmodule Sportyweb.Repo.Migrations.CreateDepartments do
  use Ecto.Migration

  def change do
    create table(:departments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :type, :string
      add :created_at, :date
      add :club_id, references(:clubs, on_delete: :nothing, type: :binary_id)
      add :parent_id, references(:departments, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:departments, [:club_id])
    create index(:departments, [:parent_id])
  end
end
