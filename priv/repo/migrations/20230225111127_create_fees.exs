defmodule Sportyweb.Repo.Migrations.CreateFees do
  use Ecto.Migration

  def change do
    create table(:fees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :name, :string
      add :reference_number, :string
      add :description, :text
      add :base_fee_in_eur_cent, :integer
      add :admission_fee_in_eur_cent, :integer
      add :is_recurring, :boolean, default: false, null: false
      add :is_group_only, :boolean, default: false, null: false
      add :minimum_age_in_years, :integer
      add :maximum_age_in_years, :integer
      add :commission_at, :date
      add :decommission_at, :date

      timestamps()
    end
  end
end
