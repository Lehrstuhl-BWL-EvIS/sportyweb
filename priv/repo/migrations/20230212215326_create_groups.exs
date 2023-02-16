defmodule Sportyweb.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false, default: ""
      add :reference_number, :string, null: false, default: ""
      add :description, :text, null: false, default: ""
      add :created_at, :date, null: false, default: nil
      add :department_id, references(:departments, on_delete: :delete_all, type: :binary_id), null: false, default: nil

      timestamps()
    end

    create index(:groups, [:department_id])
    create unique_index(:groups, [:department_id, :name])
  end
end
