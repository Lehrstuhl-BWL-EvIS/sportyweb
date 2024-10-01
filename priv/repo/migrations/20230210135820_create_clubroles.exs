defmodule Sportyweb.Repo.Migrations.CreateClubroles do
  use Ecto.Migration

  def change do
    create table(:clubroles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:clubroles, [:name])
  end
end
