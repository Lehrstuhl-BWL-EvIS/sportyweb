defmodule Sportyweb.Repo.Migrations.CreateClubs do
  use Ecto.Migration

  def change do
    create table(:clubs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :reference_number, :string, null: false
      add :description, :text, null: false
      add :website_url, :string, null: false
      add :foundation_date, :date, null: false

      timestamps()
    end
  end
end
