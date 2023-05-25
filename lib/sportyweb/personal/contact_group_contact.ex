defmodule Sportyweb.Personal.ContactGroupContact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_group_contacts" do

    field :contact_group_id, :binary_id
    field :contact_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(contact_group_contact, attrs) do
    contact_group_contact
    |> cast(attrs, [])
    |> validate_required([])
  end
end
