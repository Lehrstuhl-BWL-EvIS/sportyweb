defmodule Sportyweb.Repo.Migrations.CreateVenueEmails do
  use Ecto.Migration

  def change do
    create table(:venue_emails, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :venue_id, references(:venues, on_delete: :delete_all, type: :binary_id), null: false
      add :email_id, references(:emails, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:venue_emails, [:venue_id])
    create unique_index(:venue_emails, [:email_id])
  end
end
