defmodule Sportyweb.Calendar.EventVenue do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Venue
  alias Sportyweb.Calendar.Event

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_venues" do
    belongs_to :event, Event
    belongs_to :venue, Venue

    timestamps()
  end

  @doc false
  def changeset(event_venue, attrs) do
    event_venue
    |> cast(attrs, [:event_id, :venue_id])
    |> validate_required([:event_id, :venue_id])
    |> unique_constraint(:venue_id, name: "event_venues_venue_id_index")
  end
end
