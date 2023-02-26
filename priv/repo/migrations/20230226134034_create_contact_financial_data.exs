defmodule Sportyweb.Repo.Migrations.CreateContactFinancialData do
  use Ecto.Migration

  def change do
    create table(:contact_financial_data, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :contact_id, references(:contacts, on_delete: :nothing, type: :binary_id)
      add :financial_data_id, references(:financial_data, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:contact_financial_data, [:contact_id])
    create index(:contact_financial_data, [:financial_data_id])
  end
end
