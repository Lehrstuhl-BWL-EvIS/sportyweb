defmodule Sportyweb.Repo.Migrations.CreateContractPauses do
  use Ecto.Migration

  def change do
    create table(:contract_pauses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :starts_at, :date
      add :ends_at, :date
      add :contract_id, references(:contracts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:contract_pauses, [:contract_id])
  end
end
