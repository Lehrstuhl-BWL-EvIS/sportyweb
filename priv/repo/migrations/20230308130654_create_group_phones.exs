defmodule Sportyweb.Repo.Migrations.CreateGroupPhones do
  use Ecto.Migration

  def change do
    create table(:group_phones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :group_id, references(:groups, on_delete: :delete_all, type: :binary_id), null: false
      add :phone_id, references(:phones, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:group_phones, [:group_id])
    create unique_index(:group_phones, [:phone_id])
  end
end
