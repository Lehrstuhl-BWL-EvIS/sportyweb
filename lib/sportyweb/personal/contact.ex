defmodule Sportyweb.Personal.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contacts" do
    field :organization_name, :string
    field :person_birthday, :date
    field :person_first_name_1, :string
    field :person_first_name_2, :string
    field :person_gender, :string
    field :person_last_name, :string
    field :type, :string
    field :club_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:type, :organization_name, :person_last_name, :person_first_name_1, :person_first_name_2, :person_gender, :person_birthday])
    |> validate_required([:type, :organization_name, :person_last_name, :person_first_name_1, :person_first_name_2, :person_gender, :person_birthday])
  end
end
