defmodule Sportyweb.Organization.GroupNote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "group_notes" do

    field :group_id, :binary_id
    field :note_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(group_note, attrs) do
    group_note
    |> cast(attrs, [])
    |> validate_required([])
  end
end
