defmodule Sportyweb.Personal.ContactPostalAddress do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_postal_addresses" do

    field :contact_id, :binary_id
    field :postal_address_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(contact_postal_address, attrs) do
    contact_postal_address
    |> cast(attrs, [])
    |> validate_required([])
  end
end
