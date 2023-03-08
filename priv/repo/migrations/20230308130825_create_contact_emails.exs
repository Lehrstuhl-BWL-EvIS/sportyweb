defmodule Sportyweb.Repo.Migrations.CreateContactEmails do
  use Ecto.Migration

  def change do
    create table(:contact_emails, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :contact_id, references(:contacts, on_delete: :nothing, type: :binary_id)
      add :email_id, references(:emails, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:contact_emails, [:contact_id])
    create index(:contact_emails, [:email_id])
  end
end
