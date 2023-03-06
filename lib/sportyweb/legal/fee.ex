defmodule Sportyweb.Legal.Fee do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Club

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "fees" do
    belongs_to :club, Club
    has_many :contracts, Contract

    field :is_general, :boolean, default: false
    field :type, :string, default: ""
    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :description, :string, default: ""
    field :base_fee_in_eur_cent, :integer, default: nil
    field :admission_fee_in_eur_cent, :integer, default: nil
    field :is_recurring, :boolean, default: false
    field :is_group_only, :boolean, default: false
    field :minimum_age_in_years, :integer, default: nil
    field :maximum_age_in_years, :integer, default: nil
    field :commission_at, :date, default: nil
    field :decommission_at, :date, default: nil

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
      [key: "Event", value: "event"],
      [key: "Equipment", value: "equipment"]
    ]
  end

  @doc false
  def changeset(fee, attrs) do
    fee
    |> cast(attrs, [
      :club_id,
      :is_general,
      :type,
      :name,
      :reference_number,
      :description,
      :base_fee_in_eur_cent,
      :admission_fee_in_eur_cent,
      :is_recurring,
      :is_group_only,
      :minimum_age_in_years,
      :maximum_age_in_years,
      :commission_at,
      :decommission_at], empty_values: ["", nil])
    |> validate_required([
      :club_id,
      :type,
      :name,
      :base_fee_in_eur_cent,
      :admission_fee_in_eur_cent,
      :commission_at])
    |> validate_inclusion(
      :type,
      get_valid_types() |> Enum.map(fn type -> type[:value] end))
  end
end
