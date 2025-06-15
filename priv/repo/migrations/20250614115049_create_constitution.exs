defmodule Sportyweb.Repo.Migrations.CreateConstitution do
  use Ecto.Migration

  def change do
    create table(:constitution, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :membership_types, {:array, :string}, null: false
      add :suspension_reasons, {:array, :string}, null: false
      add :suspension_reason_mode, :string, null: false
      add :termination_notice_period, :string, null: false
      add :termination_interval, :string, null: false
      add :minimal_membership_duration, :string, null: false

      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:constitution, [:club_id])
  end
end
