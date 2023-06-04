defmodule Sportyweb.Repo.Migrations.AddVenueIdToClubs do
  use Ecto.Migration

  def change do
    alter table(:clubs) do
      add :venue_id, references(:venues, on_delete: :restrict, type: :binary_id), null: true
    end

    create index(:clubs, [:venue_id])
  end
end
