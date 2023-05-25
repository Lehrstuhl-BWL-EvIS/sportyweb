defmodule Sportyweb.Repo.Migrations.CreateContactGroupContacts do
  use Ecto.Migration

  def change do
    create table(:contact_group_contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :contact_group_id, references(:contact_groups, on_delete: :nothing, type: :binary_id)
      add :contact_id, references(:contacts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:contact_group_contacts, [:contact_group_id])
    create index(:contact_group_contacts, [:contact_id])
  end
end
