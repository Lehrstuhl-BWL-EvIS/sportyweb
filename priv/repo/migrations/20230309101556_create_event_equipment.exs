defmodule Sportyweb.Repo.Migrations.CreateEventEquipment do
  use Ecto.Migration

  def change do
    create table(:event_equipment, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :delete_all, type: :binary_id), null: false

      add :equipment_id, references(:equipment, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:event_equipment, [:event_id])
    create unique_index(:event_equipment, [:equipment_id])
  end
end
