defmodule Sportyweb.Repo.Migrations.CreateEmails do
  use Ecto.Migration

  def change do
    create table(:emails, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :address, :string
      add :is_main, :boolean, default: false, null: false

      timestamps()
    end
  end
end
