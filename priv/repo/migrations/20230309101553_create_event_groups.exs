defmodule Sportyweb.Repo.Migrations.CreateEventGroups do
  use Ecto.Migration

  def change do
    create table(:event_groups, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :delete_all, type: :binary_id), null: false
      add :group_id, references(:groups, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:event_groups, [:event_id])
    create unique_index(:event_groups, [:group_id])
  end
end
