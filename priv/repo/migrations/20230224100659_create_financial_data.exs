defmodule Sportyweb.Repo.Migrations.CreateFinancialData do
  use Ecto.Migration

  def change do
    create table(:financial_data, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :direct_debit_account_holder, :string
      add :direct_debit_iban, :string
      add :direct_debit_institute, :string
      add :invoice_recipient, :string
      add :invoice_additional_information, :text
      add :is_main, :boolean, default: false, null: false
      add :invoice_recipient_postal_address_id, references(:postal_addresses, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:financial_data, [:invoice_recipient_postal_address_id])
  end
end
