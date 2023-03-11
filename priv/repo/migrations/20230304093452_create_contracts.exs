defmodule Sportyweb.Repo.Migrations.CreateContracts do
  use Ecto.Migration

  def change do
    create table(:contracts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :signed_at, :date, null: false
      add :starts_at, :date, null: false
      add :terminated_at, :date, null: true
      add :ends_at, :date, null: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false
      add :fee_id, references(:fees, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:contracts, [:club_id])
    create index(:contracts, [:fee_id])
  end
end
