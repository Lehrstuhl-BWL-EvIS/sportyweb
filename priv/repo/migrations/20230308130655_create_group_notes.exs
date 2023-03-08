defmodule Sportyweb.Repo.Migrations.CreateGroupNotes do
  use Ecto.Migration

  def change do
    create table(:group_notes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :group_id, references(:groups, on_delete: :nothing, type: :binary_id)
      add :note_id, references(:notes, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:group_notes, [:group_id])
    create index(:group_notes, [:note_id])
  end
end
