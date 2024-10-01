defmodule Sportyweb.Repo.Migrations.CreatePhones do
  use Ecto.Migration

  def change do
    create table(:phones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :number, :string, null: false
      add :is_main, :boolean, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
