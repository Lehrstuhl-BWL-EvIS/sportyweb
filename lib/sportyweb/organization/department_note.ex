defmodule Sportyweb.Organization.DepartmentNote do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Department
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "department_notes" do
    belongs_to :department, Department
    belongs_to :note, Note

    timestamps()
  end

  @doc false
  def changeset(department_note, attrs) do
    department_note
    |> cast(attrs, [:department_id, :note_id])
    |> validate_required([:department_id, :note_id])
  end
end
