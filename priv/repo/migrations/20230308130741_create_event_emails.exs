defmodule Sportyweb.Repo.Migrations.CreateEventEmails do
  use Ecto.Migration

  def change do
    create table(:event_emails, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :nothing, type: :binary_id)
      add :email_id, references(:emails, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:event_emails, [:event_id])
    create index(:event_emails, [:email_id])
  end
end
