defmodule Sportyweb.Repo.Migrations.CreateUserclubroles do
  use Ecto.Migration

  def change do
    create table(:userclubroles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      add :clubrole_id, references(:clubroles, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps()
    end

    create index(:userclubroles, [:user_id])
    create index(:userclubroles, [:club_id])
    create index(:userclubroles, [:clubrole_id])

    create unique_index(:userclubroles, [:user_id, :club_id, :clubrole_id])
  end
end
