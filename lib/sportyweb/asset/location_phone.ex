defmodule Sportyweb.Asset.LocationPhone do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Location
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "location_phones" do
    belongs_to :location, Location
    belongs_to :phone, Phone

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(location_phone, attrs) do
    location_phone
    |> cast(attrs, [:location_id, :phone_id])
    |> validate_required([:location_id, :phone_id])
    |> unique_constraint(:phone_id, name: "location_phones_phone_id_index")
  end
end
