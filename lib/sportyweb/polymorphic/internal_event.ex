defmodule Sportyweb.Polymorphic.InternalEvent do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Finance.Fee
  alias Sportyweb.Finance.FeeInternalEvent
  alias Sportyweb.Finance.Subsidy
  alias Sportyweb.Finance.SubsidyInternalEvent
  alias Sportyweb.Polymorphic.InternalEvent

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "internal_events" do
    many_to_many :fees, Fee, join_through: FeeInternalEvent
    many_to_many :subsidies, Subsidy, join_through: SubsidyInternalEvent

    field :commission_date, :date, default: nil
    field :archive_date, :date, default: nil
    field :is_recurring, :boolean, default: false
    field :frequency, :string, default: "year"
    field :interval, :integer, default: 1

    timestamps(type: :utc_datetime)
  end

  def get_valid_frequencies do
    [
      [key: "Monat", value: "month"],
      [key: "Jahr", value: "year"]
    ]
  end

  def is_in_use?(%InternalEvent{} = internal_event, %Date{} = date \\ Date.utc_today()) do
    Date.compare(date, internal_event.commission_date) != :lt &&
      (is_nil(internal_event.archive_date) ||
         Date.compare(date, internal_event.archive_date) == :lt)
  end

  def is_archived?(%InternalEvent{} = internal_event, %Date{} = date \\ Date.utc_today()) do
    internal_event.archive_date && Date.compare(date, internal_event.archive_date) != :lt
  end

  @doc false
  def changeset(internal_event, attrs) do
    internal_event
    |> cast(
      attrs,
      [
        :commission_date,
        :archive_date,
        :is_recurring,
        :frequency,
        :interval
      ],
      empty_values: ["", nil]
    )
    |> validate_required([:commission_date])
    |> validate_dates_order(
      :commission_date,
      :archive_date,
      "Muss zeitlich später als oder gleich \"Verwendung ab\" sein!"
    )
    |> validate_inclusion(
      :frequency,
      get_valid_frequencies() |> Enum.map(fn frequency -> frequency[:value] end)
    )
    |> validate_number(:interval, greater_than_or_equal_to: 1, less_than_or_equal_to: 36)
    |> validate_required_is_recurring_condition()
  end

  defp validate_required_is_recurring_condition(%Ecto.Changeset{} = changeset) do
    # Some fields are only required if the type has a certain value.
    case get_field(changeset, :is_recurring) do
      true ->
        changeset |> validate_required([:frequency, :interval])

      _ ->
        changeset
    end
  end
end
