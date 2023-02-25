defmodule Sportyweb.RBAC.Role.DepartmentRole do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "departmentroles" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(department_role, attrs) do
    department_role
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
