defmodule Sportyweb.Repo.Migrations.CreateContactPostalAddresses do
  use Ecto.Migration

  def change do
    create table(:contact_postal_addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id), null: false, default: nil
      add :postal_address_id, references(:postal_addresses, on_delete: :delete_all, type: :binary_id), null: false, default: nil

      timestamps()
    end

    create index(:contact_postal_addresses, [:contact_id])
    create unique_index(:contact_postal_addresses, [:postal_address_id])
    create unique_index(:contact_postal_addresses, [:contact_id, :postal_address_id])
  end
end
