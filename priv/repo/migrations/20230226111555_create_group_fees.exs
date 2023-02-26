defmodule Sportyweb.Repo.Migrations.CreateGroupFees do
  use Ecto.Migration

  def change do
    create table(:group_fees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :group_id, references(:groups, on_delete: :nothing, type: :binary_id)
      add :fee_id, references(:fees, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:group_fees, [:group_id])
    create index(:group_fees, [:fee_id])
  end
end
