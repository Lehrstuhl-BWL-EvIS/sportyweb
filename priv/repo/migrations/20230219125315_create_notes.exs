defmodule Sportyweb.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
