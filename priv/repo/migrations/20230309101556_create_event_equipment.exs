defmodule Sportyweb.Repo.Migrations.CreateEventEquipment do
  use Ecto.Migration

  def change do
    create table(:event_equipment, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :nothing, type: :binary_id)
      add :equipment_id, references(:equipment, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:event_equipment, [:event_id])
    create index(:event_equipment, [:equipment_id])
  end
end
