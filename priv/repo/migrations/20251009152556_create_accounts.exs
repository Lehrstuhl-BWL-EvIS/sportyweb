defmodule Sportyweb.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :account_number, :integer, null: false
      add :name, :string, null: false
      add :class, :string, null: false

      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:accounts, [:club_id])
    create unique_index(:accounts, [:account_number, :club_id], name: :unique_account_club_index)
  end
end
