defmodule Sportyweb.Repo.Migrations.CreatePostalAddresses do
  use Ecto.Migration

  def change do
    create table(:postal_addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :street, :string, null: false
      add :street_number, :string, null: false
      add :street_additional_information, :string, null: false
      add :zipcode, :string, null: false
      add :city, :string, null: false
      add :country, :string, null: false
      add :is_main, :boolean, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
