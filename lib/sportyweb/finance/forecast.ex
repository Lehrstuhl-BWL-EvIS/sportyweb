defmodule Sportyweb.Finance.Forecast do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  schema "forecasts" do
    field :type, :string, default: "contact", virtual: true
    field :contact_id, :string, default: "", virtual: true
    field :subsidy_id, :string, default: "", virtual: true
    field :current_date, :date, default: Date.utc_today(), virtual: true
    field :start_date, :date, default: nil, virtual: true
    field :end_date, :date, default: nil, virtual: true
  end

  def get_valid_types do
    [
      [key: "Gebühren von Kontakten", value: "contact"],
      [key: "Zuschüsse", value: "subsidy"]
    ]
  end

  @doc false
  def changeset(forecast, attrs) do
    forecast
    |> cast(
      attrs,
      [
        :type,
        :contact_id,
        :subsidy_id,
        :start_date,
        :end_date
      ],
      empty_values: ["", nil]
    )
    |> validate_required([:type, :start_date, :end_date])
    |> validate_dates_order(
      :current_date,
      :start_date,
      "Startzeitpunkt darf nicht in der Vergangenheit liegen!"
    )
    |> validate_dates_order(
      :start_date,
      :end_date,
      "Muss zeitlich später als oder gleich \"Von\" sein!"
    )
  end
end
