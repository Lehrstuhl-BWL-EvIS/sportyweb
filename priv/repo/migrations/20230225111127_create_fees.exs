defmodule Sportyweb.Repo.Migrations.CreateFees do
  use Ecto.Migration

  def change do
    create table(:fees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_general, :boolean, null: false, default: false
      add :type, :string, null: false, default: ""
      add :name, :string, null: false, default: ""
      add :reference_number, :string, null: false, default: ""
      add :description, :text, null: false, default: ""
      add :base_fee_in_eur_cent, :integer, null: false, default: nil
      add :admission_fee_in_eur_cent, :integer, null: false, default: nil
      add :is_recurring, :boolean, null: false, default: false
      add :is_group_only, :boolean, null: false, default: false
      add :minimum_age_in_years, :integer, null: true, default: nil
      add :maximum_age_in_years, :integer, null: true, default: nil
      add :commission_at, :date, null: false, default: nil
      add :decommission_at, :date, null: true, default: nil
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false, default: nil

      timestamps()
    end

    create index(:fees, [:club_id])
  end
end
