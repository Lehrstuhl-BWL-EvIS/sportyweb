defmodule Sportyweb.RBAC.UserRole.UserDepartmentRole do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "userdepartmentroles" do

    field :user_id, :binary_id
    field :department_id, :binary_id
    field :departmentrole_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(user_department_role, attrs) do
    user_department_role
    |> cast(attrs, [])
    |> validate_required([])
  end
end
