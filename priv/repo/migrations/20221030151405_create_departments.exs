defmodule Sportyweb.Repo.Migrations.CreateDepartments do
  use Ecto.Migration

  def change do
    create table(:departments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false, default: ""
      add :reference_number, :string, null: false, default: ""
      add :description, :text, null: false, default: ""
      add :created_at, :date, null: false, default: nil
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false, default: nil

      timestamps()
    end

    create index(:departments, [:club_id])
    create unique_index(:departments, [:club_id, :name])
  end
end
