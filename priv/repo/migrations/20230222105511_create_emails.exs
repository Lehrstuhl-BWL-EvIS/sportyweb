defmodule Sportyweb.Repo.Migrations.CreateEmails do
  use Ecto.Migration

  def change do
    create table(:emails, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :address, :string, null: false
      add :is_main, :boolean, null: false

      timestamps()
    end
  end
end
