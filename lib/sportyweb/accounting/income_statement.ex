defmodule Sportyweb.Accounting.IncomeStatement do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  schema "income_statements" do
    field :start_date, :date, default: nil, virtual: true
    field :end_date, :date, default: nil, virtual: true
  end

  @doc false
  def changeset(income_statement, attrs) do
    income_statement
    |> cast(
      attrs,
      [
        :start_date,
        :end_date
      ]
    )
    |> validate_required([:start_date, :end_date])
    |> validate_dates_order(
      :start_date,
      :end_date,
      "Muss zeitlich später als oder gleich \"Von\" sein!"
    )
  end
end
