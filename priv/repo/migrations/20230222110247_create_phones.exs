defmodule Sportyweb.Repo.Migrations.CreatePhones do
  use Ecto.Migration

  def change do
    create table(:phones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false, default: ""
      add :number, :string, null: false, default: ""
      add :is_main, :boolean, null: false, default: false

      timestamps()
    end
  end
end
