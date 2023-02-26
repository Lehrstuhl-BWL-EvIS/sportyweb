defmodule Sportyweb.Repo.Migrations.CreateClubFee do
  use Ecto.Migration

  def change do
    create table(:club_fee, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false, default: nil
      add :fee_id, references(:fees, on_delete: :delete_all, type: :binary_id), null: false, default: nil

      timestamps()
    end

    create index(:club_fee, [:club_id])
    create unique_index(:club_fee, [:fee_id])
    create unique_index(:club_fee, [:club_id, :fee_id])
  end
end
