defmodule Sportyweb.Legal.Contract do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.ContractPause
  alias Sportyweb.Legal.Fee
  alias Sportyweb.Organization.Club

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contracts" do
    belongs_to :club, Club
    belongs_to :fee, Fee
    has_many :contract_pauses, ContractPause

    field :signing_date, :date, default: nil
    field :start_date, :date, default: nil
    field :termination_date, :date, default: nil
    field :end_date, :date, default: nil

    timestamps()
  end

  @doc false
  def changeset(contract, attrs) do
    contract
    |> cast(attrs, [
      :club_id,
      :fee_id,
      :signing_date,
      :start_date,
      :termination_date,
      :end_date],
      empty_values: ["", nil]
    )
    |> validate_required([:club_id, :fee_id, :signing_date, :start_date])
  end
end
