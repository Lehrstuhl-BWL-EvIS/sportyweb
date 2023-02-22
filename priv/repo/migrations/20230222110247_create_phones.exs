defmodule Sportyweb.Repo.Migrations.CreatePhones do
  use Ecto.Migration

  def change do
    create table(:phones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :number, :string
      add :is_main, :boolean, default: false, null: false

      timestamps()
    end
  end
end
