defmodule Sportyweb.Calendar.EventPostalAddress do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Calendar.Event
  alias Sportyweb.Polymorphic.PostalAddress

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_postal_addresses" do
    belongs_to :event, Event
    belongs_to :postal_address, PostalAddress

    timestamps()
  end

  @doc false
  def changeset(event_postal_address, attrs) do
    event_postal_address
    |> cast(attrs, [:event_id, :postal_address_id])
    |> validate_required([:event_id, :postal_address_id])
    |> unique_constraint(:postal_address_id, name: "event_postal_addresses_postal_address_id_index")
  end
end