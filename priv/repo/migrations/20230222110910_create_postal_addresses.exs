defmodule Sportyweb.Repo.Migrations.CreatePostalAddresses do
  use Ecto.Migration

  def change do
    create table(:postal_addresses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :street, :string, null: false, default: ""
      add :street_number, :string, null: false, default: ""
      add :street_additional_information, :string, null: false, default: ""
      add :zipcode, :string, null: false, default: ""
      add :city, :string, null: false, default: ""
      add :country, :string, null: false, default: ""
      add :is_main, :boolean, null: false, default: false

      timestamps()
    end
  end
end
