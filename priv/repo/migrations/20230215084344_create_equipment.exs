defmodule Sportyweb.Repo.Migrations.CreateEquipment do
  use Ecto.Migration

  def change do
    create table(:equipment, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :reference_number, :string, null: false
      add :serial_number, :string, null: false
      add :description, :text, null: false
      add :purchased_at, :date, null: true
      add :commission_at, :date, null: true
      add :decommission_at, :date, null: true
      add :venue_id, references(:venues, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:equipment, [:venue_id])
  end
end
