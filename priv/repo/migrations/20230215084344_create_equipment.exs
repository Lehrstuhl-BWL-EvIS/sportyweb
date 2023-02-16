defmodule Sportyweb.Repo.Migrations.CreateEquipment do
  use Ecto.Migration

  def change do
    create table(:equipment, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false, default: ""
      add :reference_number, :string, null: false, default: ""
      add :serial_number, :string, null: false, default: ""
      add :description, :text, null: false, default: ""
      add :purchased_at, :date, null: true, default: nil
      add :commission_at, :date, null: true, default: nil
      add :decommission_at, :date, null: true, default: nil
      add :venue_id, references(:venues, on_delete: :delete_all, type: :binary_id), null: false, default: nil

      timestamps()
    end

    create index(:equipment, [:venue_id])
    create unique_index(:equipment, [:venue_id, :name])
  end
end
