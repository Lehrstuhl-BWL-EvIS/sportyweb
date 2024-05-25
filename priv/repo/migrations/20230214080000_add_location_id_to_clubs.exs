defmodule Sportyweb.Repo.Migrations.AddLocationIdToClubs do
  use Ecto.Migration

  def change do
    alter table(:clubs) do
      add :location_id, references(:locations, on_delete: :restrict, type: :binary_id), null: true
    end

    create index(:clubs, [:location_id])
  end
end
