defmodule Sportyweb.Repo.Migrations.CreateEventPostalAddresses do
  use Ecto.Migration

  def change do
    create table(:event_postal_addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :delete_all, type: :binary_id), null: false

      add :postal_address_id,
          references(:postal_addresses, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:event_postal_addresses, [:event_id])
    create unique_index(:event_postal_addresses, [:postal_address_id])
  end
end
