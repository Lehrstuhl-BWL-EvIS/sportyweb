defmodule Sportyweb.Organization.DepartmentNote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "department_notes" do

    field :department_id, :binary_id
    field :note_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(department_note, attrs) do
    department_note
    |> cast(attrs, [])
    |> validate_required([])
  end
end
