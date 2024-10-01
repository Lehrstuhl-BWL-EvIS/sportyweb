defmodule Sportyweb.Repo.Migrations.CreateLocationPostalAddresses do
  use Ecto.Migration

  def change do
    create table(:location_postal_addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :location_id, references(:locations, on_delete: :delete_all, type: :binary_id),
        null: false

      add :postal_address_id,
          references(:postal_addresses, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:location_postal_addresses, [:location_id])
    create unique_index(:location_postal_addresses, [:postal_address_id])
  end
end
