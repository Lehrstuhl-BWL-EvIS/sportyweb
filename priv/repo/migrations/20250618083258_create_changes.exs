defmodule Sportyweb.Repo.Migrations.CreateChanges do
  use Ecto.Migration

  def change do
    create table(:changes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :entity_type, :string, null: false
      add :entity_id, :binary, null: false
      add :changed_by, :string, null: false
      add :changed_at, :utc_datetime, null: false
      add :attribute, :string, null: false
      add :new_value, :text, null: true

      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:changes, [:entity_id])
    create index(:changes, [:changed_at])
    create index(:changes, [:club_id])
  end
end
