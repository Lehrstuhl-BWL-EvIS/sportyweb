defmodule Sportyweb.Organization.GroupContract do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Group

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "group_contracts" do
    belongs_to :group, Group
    belongs_to :contract, Contract

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group_contract, attrs) do
    group_contract
    |> cast(attrs, [:group_id, :contract_id])
    |> validate_required([:group_id, :contract_id])
  end
end
