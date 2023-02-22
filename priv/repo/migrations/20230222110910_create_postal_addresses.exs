defmodule Sportyweb.Repo.Migrations.CreatePostalAddresses do
  use Ecto.Migration

  def change do
    create table(:postal_addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :street, :string
      add :street_number, :string
      add :street_additional_information, :string
      add :zipcode, :string
      add :city, :string
      add :country, :string
      add :is_main, :boolean, default: false, null: false

      timestamps()
    end
  end
end
