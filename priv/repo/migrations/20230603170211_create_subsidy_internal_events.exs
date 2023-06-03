defmodule Sportyweb.Repo.Migrations.CreateSubsidyInternalEvents do
  use Ecto.Migration

  def change do
    create table(:subsidy_internal_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :subsidy_id, references(:subsidies, on_delete: :nothing, type: :binary_id)
      add :internal_event_id, references(:internal_events, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:subsidy_internal_events, [:subsidy_id])
    create index(:subsidy_internal_events, [:internal_event_id])
  end
end
