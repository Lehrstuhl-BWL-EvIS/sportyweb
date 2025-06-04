defmodule Sportyweb.Repo.Migrations.CreateDocumentComments do
  use Ecto.Migration

  def change do
    create table(:document_comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :comment, :text, null: false, default: ""

      add :document_id, references(:documents, type: :binary_id, on_delete: :delete_all),
        null: false

      add :commented_by_id, references(:users, type: :binary_id, on_delete: :nothing),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:document_comments, [:document_id])
    create index(:document_comments, [:commented_by_id])
  end
end
