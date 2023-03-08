defmodule Sportyweb.Repo.Migrations.CreateClubEmails do
  use Ecto.Migration

  def change do
    create table(:club_emails, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :club_id, references(:clubs, on_delete: :nothing, type: :binary_id)
      add :email_id, references(:emails, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:club_emails, [:club_id])
    create index(:club_emails, [:email_id])
  end
end
