defmodule Sportyweb.Asset.LocationFee do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Location
  alias Sportyweb.Finance.Fee

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "location_fees" do
    belongs_to :location, Location
    belongs_to :fee, Fee

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(location_fee, attrs) do
    location_fee
    |> cast(attrs, [:location_id, :fee_id])
    |> validate_required([:location_id, :fee_id])
    |> unique_constraint(:fee_id, name: "location_fees_fee_id_index")
  end
end
