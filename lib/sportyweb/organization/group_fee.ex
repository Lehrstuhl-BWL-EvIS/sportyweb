defmodule Sportyweb.Organization.GroupFee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Group
  alias Sportyweb.Legal.Fee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "group_fees" do
    belongs_to :group, Group
    belongs_to :fee, Fee

    timestamps()
  end

  @doc false
  def changeset(group_fee, attrs) do
    group_fee
    |> cast(attrs, [:group_id, :fee_id])
    |> validate_required([:group_id, :fee_id])
    |> unique_constraint(:club_id, name: "group_fees_group_id_fee_id_index")
  end
end
