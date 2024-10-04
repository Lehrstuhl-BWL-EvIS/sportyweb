defmodule Sportyweb.Organization.GroupFee do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Finance.Fee
  alias Sportyweb.Organization.Group

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "group_fees" do
    belongs_to :group, Group
    belongs_to :fee, Fee

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(group_fee, attrs) do
    group_fee
    |> cast(attrs, [:group_id, :fee_id])
    |> validate_required([:group_id, :fee_id])
    |> unique_constraint(:fee_id, name: "group_fees_fee_id_index")
  end
end
