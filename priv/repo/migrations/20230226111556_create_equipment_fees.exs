defmodule Sportyweb.Repo.Migrations.CreateEquipmentFees do
  use Ecto.Migration

  def change do
    create table(:equipment_fees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :equipment_id, references(:equipments, on_delete: :nothing, type: :binary_id)
      add :fee_id, references(:fees, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:equipment_fees, [:equipment_id])
    create index(:equipment_fees, [:fee_id])
  end
end
