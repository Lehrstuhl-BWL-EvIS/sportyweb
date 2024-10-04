defmodule Sportyweb.Calendar.EventNote do
  @moduledoc """
  Associative entity, part of a polymorphic association with many to many.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Calendar.Event
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_notes" do
    belongs_to :event, Event
    belongs_to :note, Note

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_note, attrs) do
    event_note
    |> cast(attrs, [:event_id, :note_id])
    |> validate_required([:event_id, :note_id])
    |> unique_constraint(:note_id, name: "event_notes_note_id_index")
  end
end
