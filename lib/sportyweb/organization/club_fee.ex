defmodule Sportyweb.Organization.ClubFee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Legal.Fee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "club_fee" do
    belongs_to :club_id, Club
    belongs_to :fee_id, Fee

    timestamps()
  end

  @doc false
  def changeset(club_fee, attrs) do
    club_fee
    |> cast(attrs, [:club_id, :fee_id])
    |> validate_required([:club_id, :fee_id])
    |> unique_constraint(:club_id, name: "club_fees_club_id_fee_id_index")
  end
end
