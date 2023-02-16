defmodule Sportyweb.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :organization_name, :string
      add :person_last_name, :string
      add :person_first_name_1, :string
      add :person_first_name_2, :string
      add :person_gender, :string
      add :person_birthday, :date
      add :club_id, references(:clubs, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:contacts, [:club_id])
  end
end
