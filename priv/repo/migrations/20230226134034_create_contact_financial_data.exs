defmodule Sportyweb.Repo.Migrations.CreateContactFinancialData do
  use Ecto.Migration

  def change do
    create table(:contact_financial_data, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id), null: false
      add :financial_data_id, references(:financial_data, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:contact_financial_data, [:contact_id])
    create unique_index(:contact_financial_data, [:financial_data_id])
    create unique_index(:contact_financial_data, [:contact_id, :financial_data_id])
  end
end
