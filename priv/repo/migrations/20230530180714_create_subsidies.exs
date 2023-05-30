defmodule Sportyweb.Repo.Migrations.CreateSubsidies do
  use Ecto.Migration

  def change do
    create table(:subsidies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :reference_number, :string
      add :description, :text
      add :value, :integer
      add :commission_date, :date
      add :archive_date, :date
      add :club_id, references(:clubs, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:subsidies, [:club_id])
  end
end
