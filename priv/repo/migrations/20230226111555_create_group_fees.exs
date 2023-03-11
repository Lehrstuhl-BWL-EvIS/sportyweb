defmodule Sportyweb.Repo.Migrations.CreateGroupFees do
  use Ecto.Migration

  def change do
    create table(:group_fees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :group_id, references(:groups, on_delete: :delete_all, type: :binary_id), null: false
      add :fee_id, references(:fees, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:group_fees, [:group_id])
    create unique_index(:group_fees, [:fee_id])
  end
end
