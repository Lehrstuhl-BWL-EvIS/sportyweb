defmodule Sportyweb.Repo.Migrations.CreateEventVenues do
  use Ecto.Migration

  def change do
    create table(:event_venues, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :delete_all, type: :binary_id), null: false
      add :venue_id, references(:venues, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:event_venues, [:event_id])
    create unique_index(:event_venues, [:venue_id])
  end
end
