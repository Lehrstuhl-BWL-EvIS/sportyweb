defmodule Sportyweb.Repo.Migrations.CreateClubPhones do
  use Ecto.Migration

  def change do
    create table(:club_phones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :club_id, references(:clubs, on_delete: :nothing, type: :binary_id)
      add :phone_id, references(:phones, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:club_phones, [:club_id])
    create index(:club_phones, [:phone_id])
  end
end
