defmodule Sportyweb.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :reference_number, :string
      add :status, :string
      add :description, :text
      add :minimum_participants, :integer
      add :maximum_participants, :integer
      add :minimum_age_in_years, :integer
      add :maximum_age_in_years, :integer
      add :location_type, :string
      add :location_description, :string

      timestamps()
    end
  end
end
