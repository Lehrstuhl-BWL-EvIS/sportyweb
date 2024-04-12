defmodule Sportyweb.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :amount, :money_with_currency
      add :creation_date, :date, null: false
      add :payment_date, :date, null: true

      add :contract_id, references(:contracts, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps()
    end

    create index(:transactions, [:contract_id])
  end
end
