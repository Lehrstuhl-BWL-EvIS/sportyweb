defmodule Sportyweb.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :amount, :money_with_currency
      add :creation_date, :date, null: false
      add :payment_date, :date, null: true
      add :due_date, :date, null: true
      add :receipt_number, :string, null: true
      add :type, :string, null: false
      add :is_recurring, :boolean, null: true

      add :contract_id, references(:contracts, on_delete: :delete_all, type: :binary_id),
        null: true

      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false
      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id), null: true

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:contract_id])
    create index(:transactions, [:contact_id])
    create index(:transactions, [:club_id])

    create unique_index(:transactions, [:receipt_number, :club_id],
             name: :unique_receipt_number_club_index
           )
  end
end
