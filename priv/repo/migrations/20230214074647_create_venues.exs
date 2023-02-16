defmodule Sportyweb.Repo.Migrations.CreateVenues do
  use Ecto.Migration

  def change do
    create table(:venues, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false, default: ""
      add :reference_number, :string, null: false, default: ""
      add :description, :text, null: false, default: ""
      add :is_main, :boolean, null: false, default: false
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false, default: nil

      timestamps()
    end

    create index(:venues, [:club_id])
    create unique_index(:venues, [:club_id, :name])
  end
end
