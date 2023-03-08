defmodule Sportyweb.Repo.Migrations.CreateGroupPhones do
  use Ecto.Migration

  def change do
    create table(:group_phones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :group_id, references(:groups, on_delete: :nothing, type: :binary_id)
      add :phone_id, references(:phones, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:group_phones, [:group_id])
    create index(:group_phones, [:phone_id])
  end
end
