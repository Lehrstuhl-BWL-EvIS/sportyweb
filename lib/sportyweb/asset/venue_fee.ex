defmodule Sportyweb.Asset.VenueFee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Venue
  alias Sportyweb.Legal.Fee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "venue_fees" do
    belongs_to :venue, Venue
    belongs_to :fee, Fee

    timestamps()
  end

  @doc false
  def changeset(venue_fee, attrs) do
    venue_fee
    |> cast(attrs, [:venue_id, :fee_id])
    |> validate_required([:venue_id, :fee_id])
    |> unique_constraint(:fee_id, name: "venue_fees_fee_id_index")
  end
end
