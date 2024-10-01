defmodule Sportyweb.Repo.Migrations.CreateClubPhones do
  use Ecto.Migration

  def change do
    create table(:club_phones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false
      add :phone_id, references(:phones, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:club_phones, [:club_id])
    create unique_index(:club_phones, [:phone_id])
  end
end
