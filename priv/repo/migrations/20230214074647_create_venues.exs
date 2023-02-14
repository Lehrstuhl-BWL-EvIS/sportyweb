defmodule Sportyweb.Repo.Migrations.CreateVenues do
  use Ecto.Migration

  def change do
    create table(:venues, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_main, :boolean, default: false, null: false
      add :name, :string
      add :reference_number, :string
      add :description, :text
      add :club_id, references(:clubs, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:venues, [:club_id])
  end
end
