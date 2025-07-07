defmodule Sportyweb.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string, null: false
      add :name, :string, null: false
      add :organization_name, :string, null: false
      add :organization_type, :string, null: false
      add :person_last_name, :string, null: false
      add :person_first_name, :string, null: false
      add :person_gender, :string, null: false
      add :person_birthday, :date, null: true

      add :email, :string, null: false
      add :phone, :string, null: false
      add :note, :text, null: false
      add :address_as_text, :text, null: false
      add :address, :map
      add :financial_data, :map

      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:contacts, [:club_id])
  end
end
