defmodule Sportyweb.Repo.Migrations.CreateClubContracts do
  use Ecto.Migration

  def change do
    create table(:club_contracts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :club_id, references(:clubs, on_delete: :nothing, type: :binary_id)
      add :contract_id, references(:contracts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:club_contracts, [:club_id])
    create index(:club_contracts, [:contract_id])
  end
end
