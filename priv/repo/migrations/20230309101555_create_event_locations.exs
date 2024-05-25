defmodule Sportyweb.Repo.Migrations.CreateEventLocations do
  use Ecto.Migration

  def change do
    create table(:event_locations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :delete_all, type: :binary_id), null: false

      add :location_id, references(:locations, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps()
    end

    create index(:event_locations, [:event_id])
    create unique_index(:event_locations, [:event_id, :location_id])
  end
end
