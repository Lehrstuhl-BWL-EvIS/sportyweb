defmodule Sportyweb.Repo.Migrations.CreateEquipment do
  use Ecto.Migration

  def change do
    create table(:equipment, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :reference_number, :string, null: false
      add :serial_number, :string, null: false
      add :description, :text, null: false
      add :purchase_date, :date, null: true
      add :commission_date, :date, null: true
      add :decommission_date, :date, null: true

      add :location_id, references(:locations, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps()
    end

    create index(:equipment, [:location_id])
  end
end
