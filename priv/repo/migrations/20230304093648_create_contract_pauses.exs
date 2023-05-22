defmodule Sportyweb.Repo.Migrations.CreateContractPauses do
  use Ecto.Migration

  def change do
    create table(:contract_pauses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start_date, :date, null: false
      add :end_date, :date, null: false
      add :contract_id, references(:contracts, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:contract_pauses, [:contract_id])
  end
end
