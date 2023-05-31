defmodule Sportyweb.Calendar.Event do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Asset.Venue
  alias Sportyweb.Calendar.EventDepartment
  alias Sportyweb.Calendar.EventEmail
  alias Sportyweb.Calendar.EventEquipment
  alias Sportyweb.Calendar.EventFee
  alias Sportyweb.Calendar.EventGroup
  alias Sportyweb.Calendar.EventNote
  alias Sportyweb.Calendar.EventPhone
  alias Sportyweb.Calendar.EventPostalAddress
  alias Sportyweb.Calendar.EventVenue
  alias Sportyweb.Legal.Fee
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.Group
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone
  alias Sportyweb.Polymorphic.PostalAddress

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    belongs_to :club, Club
    many_to_many :departments, Department, join_through: EventDepartment
    many_to_many :emails, Email, join_through: EventEmail
    many_to_many :equipment, Equipment, join_through: EventEquipment
    many_to_many :fees, Fee, join_through: EventFee
    many_to_many :groups, Group, join_through: EventGroup
    many_to_many :notes, Note, join_through: EventNote
    many_to_many :phones, Phone, join_through: EventPhone
    many_to_many :postal_addresses, PostalAddress, join_through: EventPostalAddress
    many_to_many :venues, Venue, join_through: EventVenue

    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :status, :string, default: ""
    field :description, :string, default: ""
    field :minimum_participants, :integer, default: nil
    field :maximum_participants, :integer, default: nil
    field :minimum_age_in_years, :integer, default: nil
    field :maximum_age_in_years, :integer, default: nil
    field :location_type, :string, default: ""
    field :location_description, :string, default: ""

    timestamps()
  end

  def get_valid_statuses do
    [
      [key: "Entwurf", value: "draft"],
      [key: "Freigegeben", value: "public"],
      [key: "Abgesagt", value: "cancelled"]
    ]
  end

  def get_valid_location_types do
    [
      [key: "Keine Angabe", value: "no_info"],
      [key: "Standort", value: "venue"],
      [key: "Adresse", value: "postal_address"],
      [key: "Freifeld", value: "free_form"]
    ]
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :club_id,
      :name,
      :reference_number,
      :status,
      :description,
      :minimum_participants,
      :maximum_participants,
      :minimum_age_in_years,
      :maximum_age_in_years,
      :location_type,
      :location_description],
      empty_values: ["", nil]
    )
    |> cast_assoc(:departments, required: false)
    |> cast_assoc(:emails, required: true)
    |> cast_assoc(:equipment, required: false)
    |> cast_assoc(:groups, required: false)
    |> cast_assoc(:notes, required: true)
    |> cast_assoc(:phones, required: true)
    |> validate_required([
      :club_id,
      :name,
      :status,
      :location_type]
    )
    |> update_change(:name, &String.trim/1)
    |> update_change(:reference_number, &String.trim/1)
    |> update_change(:description, &String.trim/1)
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> validate_inclusion(
      :status,
      get_valid_statuses() |> Enum.map(fn status -> status[:value] end)
    )
    |> validate_number(:minimum_participants, greater_than_or_equal_to: 0, less_than_or_equal_to: 100_000)
    |> validate_number(:maximum_participants, greater_than_or_equal_to: 0, less_than_or_equal_to: 100_000)
    |> validate_number(:minimum_age_in_years, greater_than_or_equal_to: 0, less_than_or_equal_to: 125)
    |> validate_number(:maximum_age_in_years, greater_than_or_equal_to: 0, less_than_or_equal_to: 125)
    |> validate_numbers_order(:minimum_participants, :maximum_participants,
       "Muss größer oder gleich \"Minimale Anzahl an Teilnehmern\" sein!")
    |> validate_numbers_order(:minimum_age_in_years, :maximum_age_in_years,
       "Muss größer oder gleich \"Mindestalter\" sein!")
    |> validate_inclusion(
      :location_type,
      get_valid_location_types() |> Enum.map(fn location_type -> location_type[:value] end)
    )
    |> validate_required_location_type_condition()
    |> validate_length(:location_description, max: 20_000)
  end

  defp validate_required_location_type_condition(%Ecto.Changeset{} = changeset) do
    # Some fields are only required if the location_type has a certain value.
    case get_field(changeset, :location_type) do
      "venue" ->
        changeset |> cast_assoc(:venues, required: true)
      "postal_address" ->
        changeset |> cast_assoc(:postal_addresses, required: true)
      "free_form" ->
        changeset |> validate_required([:location_description])
      _ ->
        changeset
    end
  end
end
