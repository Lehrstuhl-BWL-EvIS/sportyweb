defmodule Sportyweb.Organization.ClubFee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "club_fee" do

    field :club_id, :binary_id
    field :fee_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(club_fee, attrs) do
    club_fee
    |> cast(attrs, [])
    |> validate_required([])
  end
end
