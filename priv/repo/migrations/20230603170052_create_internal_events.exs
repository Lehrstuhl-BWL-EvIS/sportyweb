defmodule Sportyweb.Repo.Migrations.CreateInternalEvents do
  use Ecto.Migration

  def change do
    create table(:internal_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :is_recurring, :boolean, default: false, null: false
      add :commission_date, :date
      add :archive_date, :date
      add :frequency, :string
      add :interval, :integer

      timestamps()
    end
  end
end
