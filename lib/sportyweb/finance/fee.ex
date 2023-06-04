defmodule Sportyweb.Finance.Fee do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Asset.EquipmentFee
  alias Sportyweb.Asset.Venue
  alias Sportyweb.Asset.VenueFee
  alias Sportyweb.Calendar.Event
  alias Sportyweb.Calendar.EventFee
  alias Sportyweb.Finance.Fee
  alias Sportyweb.Finance.FeeInternalEvent
  alias Sportyweb.Finance.FeeNote
  alias Sportyweb.Finance.Subsidy
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.DepartmentFee
  alias Sportyweb.Organization.Group
  alias Sportyweb.Organization.GroupFee
  alias Sportyweb.Polymorphic.InternalEvent
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "fees" do
    belongs_to :club, Club
    belongs_to :subsidy, Subsidy
    belongs_to :successor, Fee, foreign_key: :successor_id
    has_many :ancestors, Fee, foreign_key: :successor_id
    has_many :contracts, Contract
    many_to_many :departments, Department, join_through: DepartmentFee
    many_to_many :equipment, Equipment, join_through: EquipmentFee
    many_to_many :events, Event, join_through: EventFee
    many_to_many :groups, Group, join_through: GroupFee
    many_to_many :internal_events, InternalEvent, join_through: FeeInternalEvent
    many_to_many :notes, Note, join_through: FeeNote
    many_to_many :venues, Venue, join_through: VenueFee

    field :is_general, :boolean, default: false
    field :type, :string, default: ""
    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :description, :string, default: ""
    field :amount, Money.Ecto.Composite.Type, default_currency: :EUR
    field :amount_one_time, Money.Ecto.Composite.Type, default_currency: :EUR
    field :is_for_contact_group_contacts_only, :boolean, default: false
    field :minimum_age_in_years, :integer, default: nil
    field :maximum_age_in_years, :integer, default: nil

    timestamps()
  end

  @doc """
  TODO: Add an explanation regarding the apparent "duplication" of information.
  """
  def get_valid_types do
    [
      [key: "Verein", value: "club"],
      [key: "Abteilung", value: "department"],
      [key: "Gruppe", value: "group"],
      [key: "Veranstaltung", value: "event"],
      [key: "Standort", value: "venue"],
      [key: "Equipment", value: "equipment"]
    ]
  end

  def is_archived?(%Fee{} = fee) do
    Enum.any?(fee.internal_events, fn internal_event ->
      internal_event.archive_date && internal_event.archive_date <= Date.utc_today()
    end)
  end

  @doc false
  def changeset(fee, attrs) do
    fee
    |> cast(attrs, [
      :club_id,
      :subsidy_id,
      :successor_id,
      :is_general,
      :type,
      :name,
      :reference_number,
      :description,
      :amount,
      :amount_one_time,
      :is_for_contact_group_contacts_only,
      :minimum_age_in_years,
      :maximum_age_in_years],
      empty_values: ["", nil]
    )
    |> cast_assoc(:internal_events, required: true)
    |> cast_assoc(:notes, required: true)
    |> validate_required([
      :club_id,
      :type,
      :name,
      :amount,
      :amount_one_time]
    )
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type[:value] end)
    )
    |> update_change(:name, &String.trim/1)
    |> update_change(:reference_number, &String.trim/1)
    |> update_change(:description, &String.trim/1)
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> validate_number(:minimum_age_in_years, greater_than_or_equal_to: 0, less_than_or_equal_to: 125)
    |> validate_number(:maximum_age_in_years, greater_than_or_equal_to: 0, less_than_or_equal_to: 125)
    |> validate_numbers_order(:minimum_age_in_years, :maximum_age_in_years,
       "Muss größer oder gleich \"Mindestalter\" sein!")
  end
end
