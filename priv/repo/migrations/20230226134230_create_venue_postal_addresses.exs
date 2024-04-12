defmodule Sportyweb.Repo.Migrations.CreateVenuePostalAddresses do
  use Ecto.Migration

  def change do
    create table(:venue_postal_addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :venue_id, references(:venues, on_delete: :delete_all, type: :binary_id), null: false

      add :postal_address_id,
          references(:postal_addresses, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps()
    end

    create index(:venue_postal_addresses, [:venue_id])
    create unique_index(:venue_postal_addresses, [:postal_address_id])
  end
end
