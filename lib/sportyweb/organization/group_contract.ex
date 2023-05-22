defmodule Sportyweb.Organization.GroupContract do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "group_contracts" do

    field :group_id, :binary_id
    field :contract_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(group_contract, attrs) do
    group_contract
    |> cast(attrs, [])
    |> validate_required([])
  end
end
