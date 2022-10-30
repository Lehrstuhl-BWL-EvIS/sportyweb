defmodule Sportyweb.Repo.Migrations.CreateClubs do
  use Ecto.Migration

  def change do
    create table(:clubs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :reference_number, :string
      add :website_url, :string
      add :founding_date, :date

      timestamps()
    end

    create unique_index(:clubs, [:website_url])
  end
end
