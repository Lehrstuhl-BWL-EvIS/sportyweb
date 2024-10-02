defmodule Sportyweb.Calendar.EventLocation do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Location
  alias Sportyweb.Calendar.Event

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_locations" do
    belongs_to :event, Event
    belongs_to :location, Location

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_location, attrs) do
    event_location
    |> cast(attrs, [:event_id, :location_id])
    |> validate_required([:event_id, :location_id])
    |> unique_constraint(:location_id, name: "event_locations_event_id_location_id_index")
  end
end
