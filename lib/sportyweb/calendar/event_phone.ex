defmodule Sportyweb.Calendar.EventPhone do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Calendar.Event
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_phones" do
    belongs_to :event, Event
    belongs_to :phone, Phone

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_phone, attrs) do
    event_phone
    |> cast(attrs, [:event_id, :phone_id])
    |> validate_required([:event_id, :phone_id])
    |> unique_constraint(:phone_id, name: "event_phones_phone_id_index")
  end
end
