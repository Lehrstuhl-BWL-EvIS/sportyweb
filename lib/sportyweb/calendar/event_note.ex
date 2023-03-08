defmodule Sportyweb.Calendar.EventNote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_notes" do

    field :event_id, :binary_id
    field :note_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(event_note, attrs) do
    event_note
    |> cast(attrs, [])
    |> validate_required([])
  end
end
