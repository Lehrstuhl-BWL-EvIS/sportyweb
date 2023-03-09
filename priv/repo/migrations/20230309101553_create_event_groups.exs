defmodule Sportyweb.Repo.Migrations.CreateEventGroups do
  use Ecto.Migration

  def change do
    create table(:event_groups, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :nothing, type: :binary_id)
      add :group_id, references(:groups, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:event_groups, [:event_id])
    create index(:event_groups, [:group_id])
  end
end
