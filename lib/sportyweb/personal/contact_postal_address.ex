defmodule Sportyweb.Personal.ContactPostalAddress do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Polymorphic.PostalAddress

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_postal_addresses" do
    belongs_to :contact, Contact
    belongs_to :postal_address, PostalAddress

    timestamps()
  end

  @doc false
  def changeset(contact_postal_address, attrs) do
    contact_postal_address
    |> cast(attrs, [:contact_id, :postal_address_id])
    |> validate_required([:contact_id, :postal_address_id])
    |> unique_constraint(:contact_id, name: "contact_postal_addresses_contact_id_postal_address_id_index")
  end
end
