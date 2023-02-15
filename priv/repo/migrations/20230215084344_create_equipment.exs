defmodule Sportyweb.Repo.Migrations.CreateEquipment do
  use Ecto.Migration

  def change do
    create table(:equipment, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :reference_number, :string
      add :serial_number, :string
      add :description, :text
      add :purchased_at, :date
      add :commission_at, :date
      add :decommission_at, :date
      add :venue_id, references(:venues, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:equipment, [:venue_id])
  end
end
