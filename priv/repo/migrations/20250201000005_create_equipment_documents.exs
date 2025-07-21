defmodule Sportyweb.Repo.Migrations.CreateEquipmentDocuments do
  use Ecto.Migration

  def change do
    create table(:equipment_documents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false

      add :equipment_id, references(:equipment, type: :binary_id, on_delete: :delete_all), null: false
      add :document_id, references(:documents, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:equipment_documents, [:equipment_id])
    create index(:equipment_documents, [:document_id])
  end
end
