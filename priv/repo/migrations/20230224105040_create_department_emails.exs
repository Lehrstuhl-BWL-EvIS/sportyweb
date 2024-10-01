defmodule Sportyweb.Repo.Migrations.CreateDepartmentEmails do
  use Ecto.Migration

  def change do
    create table(:department_emails, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :department_id, references(:departments, on_delete: :delete_all, type: :binary_id),
        null: false

      add :email_id, references(:emails, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:department_emails, [:department_id])
    create unique_index(:department_emails, [:email_id])
  end
end
