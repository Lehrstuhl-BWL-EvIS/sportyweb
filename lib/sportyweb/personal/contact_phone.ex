defmodule Sportyweb.Personal.ContactPhone do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_phones" do
    belongs_to :contact, Contact
    belongs_to :phone, Phone

    timestamps()
  end

  @doc false
  def changeset(contact_phone, attrs) do
    contact_phone
    |> cast(attrs, [:contact_id, :phone_id])
    |> validate_required([:contact_id, :phone_id])
    |> unique_constraint(:phone_id, name: "contact_phones_phone_id_index")
  end
end
