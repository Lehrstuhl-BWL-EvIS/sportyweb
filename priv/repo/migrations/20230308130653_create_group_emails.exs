defmodule Sportyweb.Repo.Migrations.CreateGroupEmails do
  use Ecto.Migration

  def change do
    create table(:group_emails, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :group_id, references(:groups, on_delete: :delete_all, type: :binary_id), null: false
      add :email_id, references(:emails, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:group_emails, [:group_id])
    create unique_index(:group_emails, [:email_id])
  end
end
