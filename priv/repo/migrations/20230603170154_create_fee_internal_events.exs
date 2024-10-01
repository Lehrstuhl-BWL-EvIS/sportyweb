defmodule Sportyweb.Repo.Migrations.CreateFeeInternalEvents do
  use Ecto.Migration

  def change do
    create table(:fee_internal_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :fee_id, references(:fees, on_delete: :delete_all, type: :binary_id), null: false

      add :internal_event_id,
          references(:internal_events, on_delete: :delete_all, type: :binary_id),
          null: false

      timestamps(type: :utc_datetime)
    end

    create index(:fee_internal_events, [:fee_id])
    create unique_index(:fee_internal_events, [:internal_event_id])
  end
end
