defmodule Sportyweb.Repo.Migrations.CreateEmails do
  use Ecto.Migration

  def change do
    create table(:emails, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false, default: ""
      add :address, :string, null: false, default: ""
      add :is_main, :boolean, null: false, default: false

      timestamps()
    end
  end
end
