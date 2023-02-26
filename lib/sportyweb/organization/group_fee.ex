defmodule Sportyweb.Organization.GroupFee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "group_fees" do

    field :group_id, :binary_id
    field :fee_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(group_fee, attrs) do
    group_fee
    |> cast(attrs, [])
    |> validate_required([])
  end
end
