defmodule Sportyweb.Repo.Migrations.CreateFeeInternalEvents do
  use Ecto.Migration

  def change do
    create table(:fee_internal_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :fee_id, references(:fees, on_delete: :nothing, type: :binary_id)
      add :internal_event_id, references(:internal_events, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:fee_internal_events, [:fee_id])
    create index(:fee_internal_events, [:internal_event_id])
  end
end
