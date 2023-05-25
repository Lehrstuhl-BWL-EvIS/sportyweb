defmodule Sportyweb.Personal.ContactGroup do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactGroupContact

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contact_groups" do
    belongs_to :club, Club
    many_to_many :contacts, Contact, join_through: ContactGroupContact

    timestamps()
  end

  @doc false
  def changeset(contact_group, attrs) do
    contact_group
    |> cast(attrs, [:club_id])
    |> validate_required([:club_id])
  end
end
