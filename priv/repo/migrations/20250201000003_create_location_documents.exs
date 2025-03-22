defmodule Sportyweb.Repo.Migrations.CreateLocationDocuments do
  use Ecto.Migration

  def change do
    create table(:location_documents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false

      add :location_id, references(:locations, type: :binary_id, on_delete: :delete_all), null: false
      add :document_id, references(:documents, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:location_documents, [:location_id])
    create index(:location_documents, [:document_id])
  end
end
