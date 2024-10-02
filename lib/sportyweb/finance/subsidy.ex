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
    field :amount, Money.Ecto.Composite.Type, default_currency: :EUR

    timestamps(type: :utc_datetime)
  end

  def is_in_use?(%Subsidy{} = subsidy, %Date{} = date \\ Date.utc_today()) do
    Enum.any?(subsidy.internal_events, fn internal_event ->
      InternalEvent.is_in_use?(internal_event, date)
    end)
  end

  def is_archived?(%Subsidy{} = subsidy, %Date{} = date \\ Date.utc_today()) do
    Enum.any?(subsidy.internal_events, fn internal_event ->
      InternalEvent.is_archived?(internal_event, date)
    end)
  end

  @doc false
  def changeset(subsidy, attrs) do
    subsidy
    |> cast(
      attrs,
      [
        :club_id,
        :name,
        :reference_number,
        :description,
        :amount
      ],
      empty_values: ["", nil]
    )
    |> cast_assoc(:internal_events, required: true)
    |> cast_assoc(:notes, required: true)
    |> validate_required([
      :club_id,
      :name,
      :amount
    ])
    |> update_change(:name, &String.trim/1)
    |> update_change(:reference_number, &String.trim/1)
    |> update_change(:description, &String.trim/1)
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> validate_currency(:amount, :EUR)
  end
end
