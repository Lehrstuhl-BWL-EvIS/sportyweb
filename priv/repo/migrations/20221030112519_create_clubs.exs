defmodule Sportyweb.Repo.Migrations.CreateClubs do
  use Ecto.Migration

  def change do
    create table(:clubs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false, default: ""
      add :reference_number, :string, null: false, default: ""
      add :description, :text, null: false, default: ""
      add :website_url, :string, null: false, default: ""
      add :founded_at, :date, null: false, default: nil

      timestamps()
    end
  end
end
