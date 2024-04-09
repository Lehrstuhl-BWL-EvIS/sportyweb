defmodule Sportyweb.Repo.Migrations.CreateFinancialData do
  use Ecto.Migration

  def change do
    create table(:financial_data, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :direct_debit_account_holder, :string, null: false
      add :direct_debit_iban, :string, null: false
      add :direct_debit_institute, :string, null: false
      add :invoice_recipient, :string, null: false
      add :invoice_additional_information, :text, null: false
      add :is_main, :boolean, null: false

      add :invoice_recipient_postal_address_id,
          references(:postal_addresses, on_delete: :nilify_all, type: :binary_id),
          null: true

      timestamps()
    end

    create index(:financial_data, [:invoice_recipient_postal_address_id])
  end
end
