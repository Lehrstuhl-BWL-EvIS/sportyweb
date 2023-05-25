defmodule Sportyweb.Personal.ContactGroup do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_groups" do

    field :club_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(contact_group, attrs) do
    contact_group
    |> cast(attrs, [])
    |> validate_required([])
  end
end
