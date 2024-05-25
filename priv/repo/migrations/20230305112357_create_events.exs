defmodule Sportyweb.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :reference_number, :string, null: false
      add :status, :string, null: false
      add :description, :text, null: false
      add :minimum_participants, :integer, null: true
      add :maximum_participants, :integer, null: true
      add :minimum_age_in_years, :integer, null: true
      add :maximum_age_in_years, :integer, null: true
      add :venue_type, :string, null: false
      add :venue_description, :text, null: false
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:events, [:club_id])
  end
end
