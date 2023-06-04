defmodule Sportyweb.Finance.Subsidy do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Finance.Fee
  alias Sportyweb.Finance.Subsidy
  alias Sportyweb.Finance.SubsidyInternalEvent
  alias Sportyweb.Finance.SubsidyNote
  alias Sportyweb.Organization.Club
  alias Sportyweb.Polymorphic.InternalEvent
  alias Sportyweb.Polymorphic.Note

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "subsidies" do
    belongs_to :club, Club
    has_many :fees, Fee
    many_to_many :internal_events, InternalEvent, join_through: SubsidyInternalEvent
    many_to_many :notes, Note, join_through: SubsidyNote

    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :description, :string, default: ""
    field :amount, :integer, default: nil

    timestamps()
  end

  def is_archived?(%Subsidy{} = subsidy) do
    Enum.any?(subsidy.internal_events, fn internal_event ->
      internal_event.archive_date && internal_event.archive_date <= Date.utc_today()
    end)
  end

  @doc false
  def changeset(subsidy, attrs) do
    subsidy
    |> cast(attrs, [
      :club_id,
      :name,
      :reference_number,
      :description,
      :amount],
      empty_values: ["", nil]
    )
    |> cast_assoc(:internal_events, required: true)
    |> cast_assoc(:notes, required: true)
    |> validate_required([
      :club_id,
      :name,
      :amount]
    )
    |> update_change(:name, &String.trim/1)
    |> update_change(:reference_number, &String.trim/1)
    |> update_change(:description, &String.trim/1)
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> validate_number(:amount, greater_than_or_equal_to: 0, less_than_or_equal_to: 10_000)
  end
end
