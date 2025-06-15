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
    field :suspension_reason_mode, :string, default: ""
    field :termination_notice_period, :string, default: ""
    field :termination_interval, :string, default: ""
    field :minimal_membership_duration, :string, default: ""

    timestamps(type: :utc_datetime)
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

  def get_default_suspension_reasons do
    [
      "Beitragsrückstand",
      "Verstoß gegen Satzung und Ordnung",
      "Verstoß gegen Interessen des Vereins"
    ]
  end

  def get_default_suspension_reason_mode do
    "optional"
  end

  def get_next_allowed_archiving_date(
        %Constitution{} = constitution,
        after_date \\ Date.utc_today()
      ) do
    end_of_termination_notice_period =
      case constitution.termination_notice_period do
        "" ->
          after_date

        _ ->
          notice_period = Duration.from_iso8601!(constitution.termination_notice_period)
          Date.shift(after_date, notice_period)
      end

    case constitution.termination_interval do
      "" ->
        end_of_termination_notice_period

      "end_of_year" ->
        Date.new!(end_of_termination_notice_period.year, 12, 31)

      "end_of_month" ->
        Date.end_of_month(end_of_termination_notice_period)

      "end_of_half_year" ->
        if end_of_termination_notice_period.month > 6,
          do: Date.new!(end_of_termination_notice_period.year, 12, 31),
          else: Date.new!(end_of_termination_notice_period.year, 6, 30)

      "end_of_quarter" ->
        cond do
          end_of_termination_notice_period.month > 9 ->
            Date.new!(end_of_termination_notice_period.year, 12, 31)

          end_of_termination_notice_period.month > 6 ->
            Date.new!(end_of_termination_notice_period.year, 9, 30)

          end_of_termination_notice_period.month > 3 ->
            Date.new!(end_of_termination_notice_period.year, 6, 30)

          true ->
            Date.new!(end_of_termination_notice_period.year, 3, 31)
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
        :minimal_membership_duration
      ],
      empty_values: [nil, ""]
    )
    |> cast(
         attrs,
         [
           :membership_types,
           :suspension_reasons,
         ],
         empty_values: [nil] # keep "" here, otherwise ["", ""] would be changed to []
       )
    |> validate_required([
      :club_id,
      :membership_types,
      :suspension_reasons,
      :suspension_reason_mode,
      :termination_interval
    ])
    |> validate_inclusion(
      :suspension_reason_mode,
      get_suspension_reasons_modes() |> Enum.map(fn mode -> mode[:value] end)
    )
    |> validate_inclusion(
      :termination_interval,
      get_termination_intervals() |> Enum.map(fn interval -> interval[:value] end)
    )
  end
end
