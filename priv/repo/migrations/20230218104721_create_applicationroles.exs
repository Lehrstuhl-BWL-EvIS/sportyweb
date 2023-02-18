defmodule Sportyweb.Repo.Migrations.CreateApplicationroles do
  use Ecto.Migration

  def change do
    create table(:applicationroles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string

      timestamps()
    end

    create unique_index(:applicationroles, [:name])
  end
end
