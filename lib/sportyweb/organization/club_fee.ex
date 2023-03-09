defmodule Sportyweb.Organization.ClubFee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Legal.Fee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "club_fees" do
    belongs_to :club, Club
    belongs_to :fee, Fee

    timestamps()
  end

  @doc false
  def changeset(club_fee, attrs) do
    club_fee
    |> cast(attrs, [:club_id, :fee_id])
    |> validate_required([:club_id, :fee_id])
    |> unique_constraint(:club_id, name: "club_fees_fee_id_index")
  end
end
