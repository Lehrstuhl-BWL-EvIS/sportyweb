defmodule Sportyweb.Repo.Migrations.CreateLocationPhones do
  use Ecto.Migration

  def change do
    create table(:location_phones, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :location_id, references(:locations, on_delete: :delete_all, type: :binary_id),
        null: false

      add :phone_id, references(:phones, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:location_phones, [:location_id])
    create unique_index(:location_phones, [:phone_id])
  end
end
