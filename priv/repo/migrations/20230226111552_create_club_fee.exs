defmodule Sportyweb.Repo.Migrations.CreateClubFee do
  use Ecto.Migration

  def change do
    create table(:club_fee, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :club_id, references(:clubs, on_delete: :nothing, type: :binary_id)
      add :fee_id, references(:fees, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:club_fee, [:club_id])
    create index(:club_fee, [:fee_id])
  end
end
