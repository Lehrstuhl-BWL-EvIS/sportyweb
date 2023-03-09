defmodule Sportyweb.Repo.Migrations.CreateEventFees do
  use Ecto.Migration

  def change do
    create table(:event_fees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :delete_all, type: :binary_id), null: false
      add :fee_id, references(:fees, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:event_fees, [:event_id])
    create unique_index(:event_fees, [:fee_id])
  end
end
