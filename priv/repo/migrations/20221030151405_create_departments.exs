defmodule Sportyweb.Repo.Migrations.CreateDepartments do
  use Ecto.Migration

  def change do
    create table(:departments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false, default: ""
      add :reference_number, :string, null: false, default: ""
      add :description, :text, null: false, default: ""
      add :created_at, :date, null: false
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false
      add :parent_id, references(:departments, on_delete: :nothing, type: :binary_id) # NULL if department is not a parent

      timestamps()
    end

    create index(:departments, [:club_id])
    create index(:departments, [:parent_id])
    create unique_index(:departments, [:club_id, :parent_id, :name])
  end
end
