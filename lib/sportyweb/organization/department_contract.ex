defmodule Sportyweb.Organization.DepartmentContract do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Department

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "department_contracts" do
    belongs_to :department, Department
    belongs_to :contract, Contract

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(department_contract, attrs) do
    department_contract
    |> cast(attrs, [:department_id, :contract_id])
    |> validate_required([:department_id, :contract_id])
  end
end
