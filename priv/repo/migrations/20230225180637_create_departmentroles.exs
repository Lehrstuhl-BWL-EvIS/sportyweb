defmodule Sportyweb.Repo.Migrations.CreateDepartmentroles do
  use Ecto.Migration

  def change do
    create table(:departmentroles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string

      timestamps()
    end

    create unique_index(:departmentroles, [:name])
  end
end
