defmodule Sportyweb.Organization.Club do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Venue
  alias Sportyweb.Calendar.Event
  alias Sportyweb.Legal.Fee
  alias Sportyweb.Organization.ClubFee
  alias Sportyweb.Organization.ClubFinancialData
  alias Sportyweb.Organization.Department
  alias Sportyweb.Polymorphic.FinancialData

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clubs" do
    has_many :all_fees, Fee
    has_many :events, Event
    has_many :departments, Department
    has_many :venues, Venue
    many_to_many :fees, Fee, join_through: ClubFee
    many_to_many :financial_data, FinancialData, join_through: ClubFinancialData

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
      ], empty_values: ["", nil])
    |> validate_required([:name, :founded_at])
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> validate_length(:website_url, max: 250)
    |> update_change(:website_url, &String.downcase/1)
  end
end
