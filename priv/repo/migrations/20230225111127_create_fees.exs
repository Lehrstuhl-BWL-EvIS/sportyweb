defmodule Sportyweb.Repo.Migrations.CreateFees do
  use Ecto.Migration

  def change do
    create table(:fees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_general, :boolean, null: false
      add :type, :string, null: false
      add :name, :string, null: false
      add :reference_number, :string, null: false
      add :description, :text, null: false
      add :base_fee_in_eur_cent, :integer, null: false
      add :admission_fee_in_eur_cent, :integer, null: false
      add :is_recurring, :boolean, null: false
      add :is_group_only, :boolean, null: false
      add :minimum_age_in_years, :integer, null: true
      add :maximum_age_in_years, :integer, null: true
      add :commission_date, :date, null: false
      add :archive_date, :date, null: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:fees, [:club_id])
  end
end
