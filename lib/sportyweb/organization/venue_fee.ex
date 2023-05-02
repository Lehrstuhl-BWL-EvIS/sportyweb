defmodule Sportyweb.Organization.VenueFee do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "venue_fees" do

    field :venue_id, :binary_id
    field :fee_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(venue_fee, attrs) do
    venue_fee
    |> cast(attrs, [])
    |> validate_required([])
  end
end
