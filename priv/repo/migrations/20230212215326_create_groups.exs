defmodule Sportyweb.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :reference_number, :string
      add :description, :text
      add :created_at, :date
      add :department_id, references(:departments, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:groups, [:department_id])
  end
end
