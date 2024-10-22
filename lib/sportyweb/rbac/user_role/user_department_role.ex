defmodule Sportyweb.RBAC.UserRole.UserDepartmentRole do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Accounts.User
  alias Sportyweb.Organization.Department
  alias Sportyweb.RBAC.Role.DepartmentRole

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "userdepartmentroles" do
    belongs_to :user, User
    belongs_to :department, Department
    belongs_to :departmentrole, DepartmentRole

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_department_role, attrs) do
    user_department_role
    |> cast(attrs, [:user_id, :department_id, :departmentrole_id])
    |> validate_required([:user_id, :department_id, :departmentrole_id])
  end
end
