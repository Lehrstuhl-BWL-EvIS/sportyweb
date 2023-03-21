defmodule Sportyweb.Organization.DepartmentFee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.Fee
  alias Sportyweb.Organization.Department

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "department_fees" do
    belongs_to :department, Department
    belongs_to :fee, Fee

    timestamps()
  end

  @doc false
  def changeset(department_fee, attrs) do
    department_fee
    |> cast(attrs, [:department_id, :fee_id])
    |> validate_required([:department_id, :fee_id])
    |> unique_constraint(:fee_id, name: "department_fees_fee_id_index")
  end
end