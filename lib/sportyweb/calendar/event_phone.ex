defmodule Sportyweb.Calendar.EventPhone do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_phones" do

    field :event_id, :binary_id
    field :phone_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(event_phone, attrs) do
    event_phone
    |> cast(attrs, [])
    |> validate_required([])
  end
end
