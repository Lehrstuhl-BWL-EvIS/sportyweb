defmodule Sportyweb.Repo.Migrations.CreateLocationEmails do
  use Ecto.Migration

  def change do
    create table(:location_emails, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :location_id, references(:locations, on_delete: :delete_all, type: :binary_id),
        null: false

      add :email_id, references(:emails, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:location_emails, [:location_id])
    create unique_index(:location_emails, [:email_id])
  end
end
