defmodule Sportyweb.Repo.Migrations.CreateEquipmentPhones do
  use Ecto.Migration

  def change do
    create table(:equipment_phones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :equipment_id, references(:equipment, on_delete: :nothing, type: :binary_id)
      add :phone_id, references(:phones, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:equipment_phones, [:equipment_id])
    create index(:equipment_phones, [:phone_id])
  end
end
