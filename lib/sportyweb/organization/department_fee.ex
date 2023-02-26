defmodule Sportyweb.Organization.DepartmentFee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "department_fees" do

    field :department_id, :binary_id
    field :fee_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(department_fee, attrs) do
    department_fee
    |> cast(attrs, [])
    |> validate_required([])
  end
end
