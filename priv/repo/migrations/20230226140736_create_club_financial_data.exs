defmodule Sportyweb.Repo.Migrations.CreateClubFinancialData do
  use Ecto.Migration

  def change do
    create table(:club_financial_data, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false
      add :financial_data_id, references(:financial_data, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:club_financial_data, [:club_id])
    create unique_index(:club_financial_data, [:financial_data_id])
  end
end
