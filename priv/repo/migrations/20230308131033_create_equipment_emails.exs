defmodule Sportyweb.Repo.Migrations.CreateEquipmentEmails do
  use Ecto.Migration

  def change do
    create table(:equipment_emails, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :equipment_id, references(:equipment, on_delete: :delete_all, type: :binary_id),
        null: false

      add :email_id, references(:emails, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:equipment_emails, [:equipment_id])
    create unique_index(:equipment_emails, [:email_id])
  end
end
