defmodule Sportyweb.Personal.ContactPostalAddress do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Polymorphic.PostalAddress

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_postal_addresses" do
    belongs_to :contact, Contact
    belongs_to :postal_address, PostalAddress

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contact_postal_address, attrs) do
    contact_postal_address
    |> cast(attrs, [:contact_id, :postal_address_id])
    |> validate_required([:contact_id, :postal_address_id])
    |> unique_constraint(:postal_address_id,
      name: "contact_postal_addresses_postal_address_id_index"
    )
  end
end
