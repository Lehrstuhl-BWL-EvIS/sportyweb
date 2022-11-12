defmodule Sportyweb.Repo.Migrations.CreateHouseholds do
  use Ecto.Migration

  def change do
    create table(:households) do
      add :identifier, :string

      timestamps()
    end

    create unique_index(:households, [:identifier])
  end
end
