defmodule Sportyweb.Calendar.EventVenue do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_venues" do

    field :event_id, :binary_id
    field :venue_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(event_venue, attrs) do
    event_venue
    |> cast(attrs, [])
    |> validate_required([])
  end
end
