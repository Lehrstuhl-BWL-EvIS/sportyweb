defmodule Sportyweb.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false, default: ""
      add :organization_name, :string, null: false, default: ""
      add :organization_type, :string, null: false, default: ""
      add :person_last_name, :string, null: false, default: ""
      add :person_first_name_1, :string, null: false, default: ""
      add :person_first_name_2, :string, null: false, default: ""
      add :person_gender, :string, null: false, default: ""
      add :person_birthday, :date, null: true, default: nil
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false, default: nil

      timestamps()
    end

    create index(:contacts, [:club_id])
  end
end
