defmodule Sportyweb.Organization.DepartmentFee do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Finance.Fee
  alias Sportyweb.Organization.Department

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "department_fees" do
    belongs_to :department, Department
    belongs_to :fee, Fee

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(department_fee, attrs) do
    department_fee
    |> cast(attrs, [:department_id, :fee_id])
    |> validate_required([:department_id, :fee_id])
    |> unique_constraint(:fee_id, name: "department_fees_fee_id_index")
  end
end
