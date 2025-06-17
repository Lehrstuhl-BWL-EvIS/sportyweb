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
    has_many :contact_group_contacts, ContactGroupContact
    field :description, :string, default: ""
    field :name, :string, default: ""

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contact_group, attrs) do
    contact_group
    |> cast(
      attrs,
      [:club_id, :name, :description],
      empty_values: ["", nil]
    )
    |> cast_assoc(:contact_group_contacts, required: false)
    |> validate_required([:club_id, :name])
    |> update_change(:name, &String.trim/1)
    |> update_change(:description, &String.trim/1)
    |> validate_length(:name, max: 250)
  end
end
