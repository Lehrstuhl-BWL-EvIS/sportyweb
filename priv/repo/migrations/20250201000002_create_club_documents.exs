defmodule Sportyweb.Repo.Migrations.CreateClubDocuments do
  use Ecto.Migration

  def change do
    create table(:club_documents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false

      add :club_id, references(:clubs, type: :binary_id, on_delete: :delete_all), null: false
      add :document_id, references(:documents, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:club_documents, [:club_id])
    create index(:club_documents, [:document_id])
  end
end
