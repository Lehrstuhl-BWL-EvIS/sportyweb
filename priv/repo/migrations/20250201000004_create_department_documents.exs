defmodule Sportyweb.Repo.Migrations.CreateDepartmentDocuments do
  use Ecto.Migration

  def change do
    create table(:department_documents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false

      add :department_id, references(:departments, type: :binary_id, on_delete: :delete_all), null: false
      add :document_id, references(:documents, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:department_documents, [:department_id])
    create index(:department_documents, [:document_id])
  end
end
