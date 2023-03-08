defmodule Sportyweb.Repo.Migrations.CreateEventPhones do
  use Ecto.Migration

  def change do
    create table(:event_phones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :nothing, type: :binary_id)
      add :phone_id, references(:phones, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:event_phones, [:event_id])
    create index(:event_phones, [:phone_id])
  end
end
