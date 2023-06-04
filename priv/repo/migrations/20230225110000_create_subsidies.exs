defmodule Sportyweb.Repo.Migrations.CreateSubsidies do
  use Ecto.Migration

  def change do
    create table(:subsidies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :reference_number, :string, null: false
      add :description, :text, null: false
      add :amount, :integer, null: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:subsidies, [:club_id])
  end
end
