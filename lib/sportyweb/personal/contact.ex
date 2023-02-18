defmodule Sportyweb.Personal.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contacts" do
    belongs_to :club, Club

    field :type, :string, default: ""
    field :organization_name, :string, default: ""
    field :person_last_name, :string, default: ""
    field :person_first_name_1, :string, default: ""
    field :person_first_name_2, :string, default: ""
    field :person_gender, :string, default: ""
    field :person_birthday, :date, default: nil

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [
      :club_id,
      :type,
      :organization_name,
      :person_last_name,
      :person_first_name_1,
      :person_first_name_2,
      :person_gender,
      :person_birthday
      ], empty_values: ["", nil])
    |> validate_required([:type])
    |> validate_length(:type, max: 250) # TODO: Validate "in key list"
    |> validate_length(:organization_name, max: 250)
    |> validate_length(:person_last_name, max: 250)
    |> validate_length(:person_first_name_1, max: 250)
    |> validate_length(:person_first_name_2, max: 250)
    |> validate_length(:person_gender, max: 250) # TODO: Validate "in key list"
  end
end
