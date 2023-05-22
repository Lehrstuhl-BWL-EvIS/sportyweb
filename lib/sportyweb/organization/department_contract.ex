defmodule Sportyweb.Organization.DepartmentContract do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "department_contracts" do

    field :department_id, :binary_id
    field :contract_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(department_contract, attrs) do
    department_contract
    |> cast(attrs, [])
    |> validate_required([])
  end
end
