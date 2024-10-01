defmodule Sportyweb.Repo.Migrations.CreateContactGroupContacts do
  use Ecto.Migration

  def change do
    create table(:contact_group_contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :contact_group_id,
          references(:contact_groups, on_delete: :delete_all, type: :binary_id),
          null: false

      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:contact_group_contacts, [:contact_group_id])
    create unique_index(:contact_group_contacts, [:contact_id])
  end
end
