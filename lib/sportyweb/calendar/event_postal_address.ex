defmodule Sportyweb.Calendar.EventPostalAddress do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_postal_addresses" do

    field :event_id, :binary_id
    field :postal_address_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(event_postal_address, attrs) do
    event_postal_address
    |> cast(attrs, [])
    |> validate_required([])
  end
end
