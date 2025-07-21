defmodule Sportyweb.Repo.Migrations.CreateGroupDocuments do
  use Ecto.Migration

  def change do
    create table(:group_documents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false

      add :group_id, references(:groups, type: :binary_id, on_delete: :delete_all), null: false
      add :document_id, references(:documents, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:group_documents, [:group_id])
    create index(:group_documents, [:document_id])
  end
end
