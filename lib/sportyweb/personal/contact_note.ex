defmodule Sportyweb.Personal.ContactNote do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_notes" do
    belongs_to :contact, Contact
    belongs_to :note, Note

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contact_note, attrs) do
    contact_note
    |> cast(attrs, [:contact_id, :note_id])
    |> validate_required([:contact_id, :note_id])
    |> unique_constraint(:note_id, name: "contact_notes_note_id_index")
  end
end
