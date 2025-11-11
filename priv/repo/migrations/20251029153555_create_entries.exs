defmodule Sportyweb.Repo.Migrations.CreateEntries do
  use Ecto.Migration

  def change do
    create table(:entries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :amount, :money_with_currency, null: false
      add :sphere, :integer, null: true

      add :transaction_id, references(:transactions, on_delete: :delete_all, type: :binary_id),
        null: false

      add :account_id, references(:accounts, on_delete: :nothing, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:entries, [:transaction_id])
    create index(:entries, [:account_id])
  end
end
