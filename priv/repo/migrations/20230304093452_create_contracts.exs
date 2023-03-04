defmodule Sportyweb.Repo.Migrations.CreateContracts do
  use Ecto.Migration

  def change do
    create table(:contracts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :signed_at, :date
      add :starts_at, :date
      add :terminated_at, :date
      add :ends_at, :date
      add :club_id, references(:clubs, on_delete: :nothing, type: :binary_id)
      add :fee_id, references(:fees, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:contracts, [:club_id])
    create index(:contracts, [:fee_id])
  end
end
