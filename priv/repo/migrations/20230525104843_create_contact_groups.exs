defmodule Sportyweb.Repo.Migrations.CreateContactGroups do
  use Ecto.Migration

  def change do
    create table(:contact_groups, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:contact_groups, [:club_id])
  end
end
