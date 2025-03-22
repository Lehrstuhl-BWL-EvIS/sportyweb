defmodule Sportyweb.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :state, :string

      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false
      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id), null: false
      add :group_id, references(:groups, on_delete: :delete_all, type: :binary_id), null: true
      add :department_id, references(:departments, on_delete: :delete_all, type: :binary_id), null: true
      add :start_date, :date, null: false
      add :termination_date, :date, null: true

      timestamps(type: :utc_datetime)
    end

    create index(:memberships, [:club_id])
    create index(:memberships, [:contact_id])
  end
end
