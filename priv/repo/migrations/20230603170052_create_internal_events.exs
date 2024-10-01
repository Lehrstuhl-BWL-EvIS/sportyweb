defmodule Sportyweb.Repo.Migrations.CreateInternalEvents do
  use Ecto.Migration

  def change do
    create table(:internal_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :commission_date, :date, null: false
      add :archive_date, :date, null: true
      add :is_recurring, :boolean, null: false
      add :frequency, :string, null: true
      add :interval, :integer, null: true

      timestamps(type: :utc_datetime)
    end
  end
end
