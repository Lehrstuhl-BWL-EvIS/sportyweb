defmodule Sportyweb.Repo.Migrations.CreateContractDocuments do
  use Ecto.Migration

  def change do
    create table(:contract_documents, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false

      add :contract_id, references(:contracts, type: :binary_id, on_delete: :delete_all), null: false
      add :document_id, references(:documents, type: :binary_id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:contract_documents, [:contract_id])
    create index(:contract_documents, [:document_id])
  end
end
