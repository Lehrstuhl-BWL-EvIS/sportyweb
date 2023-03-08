defmodule Sportyweb.Repo.Migrations.CreateVenuePhones do
  use Ecto.Migration

  def change do
    create table(:venue_phones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :venue_id, references(:venues, on_delete: :nothing, type: :binary_id)
      add :phone_id, references(:phones, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:venue_phones, [:venue_id])
    create index(:venue_phones, [:phone_id])
  end
end
