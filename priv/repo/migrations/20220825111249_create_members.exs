defmodule Sportyweb.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :firstname, :string
      add :lastname, :string
      add :gender, :string
      add :date_of_birth, :date
      add :email1, :string
      add :email2, :string
      add :phone1, :string
      add :phone2, :string
      add :is_active, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:members, [:user_id])
  end
end
