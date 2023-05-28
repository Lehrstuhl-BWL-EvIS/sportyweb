defmodule Sportyweb.Personal.ContactGroupContact do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactGroup

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_group_contacts" do
    belongs_to :contact_group, ContactGroup
    belongs_to :contact, Contact

    timestamps()
  end

  @doc false
  def changeset(contact_group_contact, attrs) do
    contact_group_contact
    |> cast(attrs, [:contact_group_id, :contact_id])
    |> validate_required([:contact_group_id, :contact_id])
    |> unique_constraint(:contact_id, name: "contact_group_contacts_contact_id_index")
  end
end