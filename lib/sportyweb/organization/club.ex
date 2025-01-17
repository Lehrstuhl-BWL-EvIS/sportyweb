defmodule Sportyweb.Organization.Club do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Location
  alias Sportyweb.Calendar.Event
  alias Sportyweb.Finance.Fee
  alias Sportyweb.Finance.Subsidy
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.ClubContract
  alias Sportyweb.Organization.ClubEmail
  alias Sportyweb.Organization.ClubFinancialData
  alias Sportyweb.Organization.ClubNote
  alias Sportyweb.Organization.ClubPhone
  alias Sportyweb.Organization.Department
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.ContactGroup
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clubs" do
    belongs_to :location, Location
    has_many :all_contracts, Contract
    has_many :all_fees, Fee
    has_many :contacts, Contact, preload_order: [asc: :name]
    has_many :contact_groups, ContactGroup
    has_many :departments, Department, preload_order: [asc: :name]
    has_many :events, Event
    has_many :subsidies, Subsidy, preload_order: [asc: :name]
    # This line has to be below "has_many :all_contracts"!
    has_many :transactions, through: [:all_contracts, :transactions]
    has_many :locations, Location, preload_order: [asc: :name]
    many_to_many :contracts, Contract, join_through: ClubContract
    many_to_many :emails, Email, join_through: ClubEmail
    many_to_many :financial_data, FinancialData, join_through: ClubFinancialData
    many_to_many :notes, Note, join_through: ClubNote
    many_to_many :phones, Phone, join_through: ClubPhone

    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :description, :string, default: ""
    field :website_url, :string, default: ""
    field :foundation_date, :date, default: nil

    timestamps(type: :utc_datetime)
  end

  def is_main_location?(%Club{} = club, %Location{} = location) do
    club.location_id == location.id
  end

  @doc false
  def changeset(club, attrs) do
    club
    |> cast(
      attrs,
      [
        :location_id,
        :name,
        :reference_number,
        :description,
        :website_url,
        :foundation_date
      ],
      empty_values: ["", nil]
    )
    |> cast_assoc(:emails, required: true)
    |> cast_assoc(:financial_data, required: true)
    |> cast_assoc(:notes, required: true)
    |> cast_assoc(:phones, required: true)
    |> validate_required([:name, :foundation_date])
    |> update_change(:name, &String.trim/1)
    |> update_change(:reference_number, &String.trim/1)
    |> update_change(:description, &String.trim/1)
    |> update_change(:website_url, &String.trim/1)
    |> update_change(:website_url, &String.downcase/1)
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> validate_length(:website_url, max: 250)
  end
end
