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
    field :organization_type, :string, default: ""
    field :person_last_name, :string, default: ""
    field :person_first_name_1, :string, default: ""
    field :person_first_name_2, :string, default: ""
    field :person_gender, :string, default: ""
    field :person_birthday, :date, default: nil

    timestamps()
  end

  def get_valid_types do
    [
      [key: "Organisation", value: "organization"],
      [key: "Person", value: "person"]
    ]
  end

  def get_valid_organization_types do
    [
      [key: "Behörde", value: "governmental_agency"],
      [key: "Gemeinnützige Organisation", value: "non_profit_organization"],
      [key: "Gemeinnütziges Unternehmen", value: "social_enterprise"],
      [key: "Stiftung", value: "charity"],
      [key: "Unternehmen", value: "corporation"],
      [key: "Verein", value: "club"],
      [key: "Vereinigung", value: "association"],
      [key: "Andere", value: "other"]
    ]
  end

  def get_valid_genders do
    [
      [key: "Männlich", value: "male"],
      [key: "Weiblich", value: "female"],
      [key: "Divers", value: "other"],
      [key: "Keine Angabe", value: "no_info"]
    ]
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [
      :club_id,
      :type,
      :organization_name,
      :organization_type,
      :person_last_name,
      :person_first_name_1,
      :person_first_name_2,
      :person_gender,
      :person_birthday
      ], empty_values: ["", nil])
    |> validate_required([:type])
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type[:value] end))
    |> validate_length(:organization_name, max: 250)
    |> validate_inclusion(
      :organization_type,
      get_valid_organization_types() |> Enum.map(fn organization_type -> organization_type[:value] end))
    |> validate_length(:person_last_name, max: 250)
    |> validate_length(:person_first_name_1, max: 250)
    |> validate_length(:person_first_name_2, max: 250)
    |> validate_inclusion(
      :person_gender,
      get_valid_genders() |> Enum.map(fn gender -> gender[:value] end))
  end
end
