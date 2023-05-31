defmodule Sportyweb.Legal.ContractPause do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Legal.Contract

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contract_pauses" do
    belongs_to :contract, Contract

    field :start_date, :date, default: nil
    field :end_date, :date, default: nil

    timestamps()
  end

  @doc false
  def changeset(contract_pause, attrs) do
    contract_pause
    |> cast(attrs, [:contract_id, :start_date, :end_date], empty_values: ["", nil])
    |> validate_required([:contract_id, :start_date, :end_date])
    |> validate_dates_order(:start_date, :end_date,
       "Muss zeitlich später als oder gleich \"Startdatum\" sein!")
  end
end
