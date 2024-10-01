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
      add :amount, :money_with_currency
      add :amount_one_time, :money_with_currency
      add :is_for_contact_group_contacts_only, :boolean, null: false
      add :minimum_age_in_years, :integer, null: true
      add :maximum_age_in_years, :integer, null: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false
      add :subsidy_id, references(:subsidies, on_delete: :restrict, type: :binary_id), null: true
      add :successor_id, references(:fees, on_delete: :restrict, type: :binary_id), null: true

      timestamps(type: :utc_datetime)
    end

    create index(:fees, [:club_id])
    create index(:fees, [:club_id, :type, :is_general])
    create index(:fees, [:subsidy_id])
    create index(:fees, [:successor_id])
  end
end
