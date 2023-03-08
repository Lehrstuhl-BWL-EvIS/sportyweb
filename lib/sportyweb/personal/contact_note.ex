defmodule Sportyweb.Personal.ContactNote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_notes" do

    field :contact_id, :binary_id
    field :note_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(contact_note, attrs) do
    contact_note
    |> cast(attrs, [])
    |> validate_required([])
  end
end
