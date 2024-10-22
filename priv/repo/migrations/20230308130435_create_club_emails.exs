defmodule Sportyweb.Repo.Migrations.CreateClubEmails do
  use Ecto.Migration

  def change do
    create table(:club_emails, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false
      add :email_id, references(:emails, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:club_emails, [:club_id])
    create unique_index(:club_emails, [:email_id])
  end
end
