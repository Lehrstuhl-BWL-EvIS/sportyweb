defmodule Sportyweb.Repo.Migrations.CreateLocationFees do
  use Ecto.Migration

  def change do
    create table(:location_fees, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :location_id, references(:locations, on_delete: :delete_all, type: :binary_id),
        null: false

      add :fee_id, references(:fees, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:location_fees, [:location_id])
    create unique_index(:location_fees, [:fee_id])
  end
end
