defmodule Sportyweb.Repo.Migrations.CreateGroupContracts do
  use Ecto.Migration

  def change do
    create table(:group_contracts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :group_id, references(:groups, on_delete: :delete_all, type: :binary_id), null: false
      add :contract_id, references(:contracts, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:group_contracts, [:group_id])
    create index(:group_contracts, [:contract_id])
  end
end
