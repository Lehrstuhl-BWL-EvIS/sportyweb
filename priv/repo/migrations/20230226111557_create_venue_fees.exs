defmodule Sportyweb.Repo.Migrations.CreateVenueFees do
  use Ecto.Migration

  def change do
    create table(:venue_fees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :venue_id, references(:venues, on_delete: :delete_all, type: :binary_id), null: false
      add :fee_id, references(:fees, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:venue_fees, [:venue_id])
    create unique_index(:venue_fees, [:fee_id])
  end
end
