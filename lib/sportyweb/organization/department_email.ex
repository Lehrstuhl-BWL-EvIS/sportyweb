defmodule Sportyweb.Organization.DepartmentEmail do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Department
  alias Sportyweb.Polymorphic.Email

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "department_emails" do
    belongs_to :department, Department
    belongs_to :email, Email

    timestamps()
  end

  @doc false
  def changeset(department_email, attrs) do
    department_email
    |> cast(attrs, [:department_id, :email_id])
    |> validate_required([:department_id, :email_id])
    |> unique_constraint(:department_id, name: "department_emails_email_id_index")
  end
end
