defmodule Sportyweb.Organization.Club do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Venue
  alias Sportyweb.Calendar.Event
  alias Sportyweb.Legal.Fee
  alias Sportyweb.Organization.ClubEmail
  alias Sportyweb.Organization.ClubFee
  alias Sportyweb.Organization.ClubFinancialData
  alias Sportyweb.Organization.ClubNote
  alias Sportyweb.Organization.ClubPhone
  alias Sportyweb.Organization.Department
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clubs" do
    has_many :all_fees, Fee
    has_many :departments, Department
    has_many :events, Event
    has_many :venues, Venue
    many_to_many :emails, Email, join_through: ClubEmail
    many_to_many :fees, Fee, join_through: ClubFee
    many_to_many :financial_data, FinancialData, join_through: ClubFinancialData
    many_to_many :notes, Note, join_through: ClubNote
    many_to_many :phones, Phone, join_through: ClubPhone

    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :description, :string, default: ""
    field :website_url, :string, default: ""
    field :founded_at, :date, default: nil

    timestamps()
  end

  @doc false
  def changeset(club, attrs) do
    club
    |> cast(attrs, [
      :name,
      :reference_number,
      :description,
      :website_url,
      :founded_at
      ],
      empty_values: ["", nil]
    )
    |> cast_assoc(:emails, required: false)
    |> cast_assoc(:financial_data, required: false)
    |> cast_assoc(:notes, required: false)
    |> cast_assoc(:phones, required: false)
    |> validate_required([:name, :founded_at])
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> validate_length(:website_url, max: 250)
    |> update_change(:website_url, &String.downcase/1)
  end
end
