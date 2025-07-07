defmodule Sportyweb.Legal.Constitution do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.Constitution
  alias Sportyweb.Organization.Club

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "constitution" do
    belongs_to :club, Club
    field :membership_types, {:array, :string}
    field :suspension_reasons, {:array, :string}
    field :suspension_reason_mode, :string, default: "optional"
    field :termination_notice_period, :string, default: ""
    field :termination_interval, :string, default: ""
    field :minimal_membership_duration, :string, default: ""

    timestamps(type: :utc_datetime)
  end

  def get_default(%Club{} = club) do
    default_suspension_reasons = [
      "Beitragsrückstand",
      "Verstoß gegen Satzung und Ordnung",
      "Verstoß gegen Interessen des Vereins"
    ]

    default_membership_types = ["ordentlich/aktiv", "passiv", "außerordentlich", "Ehrenmitglied"]

    %Constitution{
      club_id: club.id,
      club: club,
      suspension_reasons: default_suspension_reasons,
      suspension_reason_mode: "optional",
      membership_types: default_membership_types
    }
  end

  def get_suspension_reasons_modes do
    [
      [key: "erforderlich", value: "required"],
      [key: "optional", value: "optional"],
      [key: "nicht erlaubt", value: "not_allowed"]
    ]
  end

  def get_termination_intervals do
    [
      [key: "Schluss des Kalenderjahres", value: "end_of_year"],
      [key: "Schluss des Halbjahres", value: "end_of_half_year"],
      [key: "zum Quartalsende", value: "end_of_quarter"],
      [key: "zum Monatsende", value: "end_of_month"]
    ]
  end

  def get_next_allowed_archiving_date(
        %Constitution{} = constitution,
        first_allowed_date \\ nil,
        at_day \\ Date.utc_today()
      ) do
    end_of_termination_notice_period =
      case constitution.termination_notice_period do
        "" ->
          at_day

        _ ->
          notice_period = Duration.from_iso8601!(constitution.termination_notice_period)
          Date.shift(at_day, notice_period)
      end

    first_allowed_date =
      cond do
        first_allowed_date == nil -> end_of_termination_notice_period
        first_allowed_date <= end_of_termination_notice_period -> end_of_termination_notice_period
        true -> first_allowed_date
      end

    get_next_end_of_termination_interval(constitution, first_allowed_date)
  end

  defp get_next_end_of_termination_interval(%Constitution{} = constitution, first_allowed_date) do
    case constitution.termination_interval do
      "" ->
        first_allowed_date

      "end_of_year" ->
        Date.new!(first_allowed_date.year, 12, 31)

      "end_of_month" ->
        Date.end_of_month(first_allowed_date)

      "end_of_half_year" ->
        if first_allowed_date.month > 6,
          do: Date.new!(first_allowed_date.year, 12, 31),
          else: Date.new!(first_allowed_date.year, 6, 30)

      "end_of_quarter" ->
        cond do
          first_allowed_date.month > 9 ->
            Date.new!(first_allowed_date.year, 12, 31)

          first_allowed_date.month > 6 ->
            Date.new!(first_allowed_date.year, 9, 30)

          first_allowed_date.month > 3 ->
            Date.new!(first_allowed_date.year, 6, 30)

          true ->
            Date.new!(first_allowed_date.year, 3, 31)
        end
    end
  end

  @doc false
  def changeset(constitution, attrs) do
    constitution
    |> cast(
      attrs,
      [
        :club_id,
        :suspension_reason_mode,
        :termination_notice_period,
        :minimal_membership_duration,
        :termination_interval
      ],
      empty_values: [nil, ""]
    )
    |> cast(
      attrs,
      [
        :membership_types,
        :suspension_reasons
      ],
      # keep "" here, otherwise ["", ""] would be changed to []
      empty_values: [nil]
    )
    |> validate_required([
      :club_id,
      :membership_types,
      :suspension_reasons,
      :suspension_reason_mode
    ])
    |> validate_inclusion(
      :suspension_reason_mode,
      get_suspension_reasons_modes() |> Enum.map(fn mode -> mode[:value] end)
    )
    |> validate_termination_interval()
  end

  defp validate_termination_interval(%Ecto.Changeset{} = changeset) do
    case get_field(changeset, :termination_interval) do
      "" ->
        changeset

      _ ->
        changeset
        |> validate_inclusion(
          :termination_interval,
          get_termination_intervals() |> Enum.map(fn interval -> interval[:value] end)
        )
    end
  end
end
