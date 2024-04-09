defmodule Sportyweb.Repo.Migrations.CreateContactEmails do
  use Ecto.Migration

  def change do
    create table(:contact_emails, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id),
        null: false

      add :email_id, references(:emails, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:contact_emails, [:contact_id])
    create unique_index(:contact_emails, [:email_id])
  end
end
