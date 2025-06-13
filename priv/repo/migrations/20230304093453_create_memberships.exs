defmodule Sportyweb.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :state, :string, null: false
      add :suspension_reason, :string, null: false
      add :reactivation_date, :date, null: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      add :department_id, references(:departments, on_delete: :delete_all, type: :binary_id),
        null: true

      add :group_id, references(:groups, on_delete: :delete_all, type: :binary_id), null: true

      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id),
        null: false

      add :contract_id, references(:contracts, on_delete: :delete_all, type: :binary_id),
        null: true

      add :preconditional_membership_id,
          references(:memberships, on_delete: :delete_all, type: :binary_id),
          null: true

      timestamps(type: :utc_datetime)
    end

    create index(:memberships, [:club_id])
    create index(:memberships, [:contact_id])
    create index(:memberships, [:department_id])
    create index(:memberships, [:group_id])
    create index(:memberships, [:contract_id])
  end
end
