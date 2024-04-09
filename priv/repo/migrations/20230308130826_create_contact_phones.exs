defmodule Sportyweb.Repo.Migrations.CreateContactPhones do
  use Ecto.Migration

  def change do
    create table(:contact_phones, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id),
        null: false

      add :phone_id, references(:phones, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:contact_phones, [:contact_id])
    create unique_index(:contact_phones, [:phone_id])
  end
end
