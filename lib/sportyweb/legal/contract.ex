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

    field :signed_at, :date, default: nil
    field :starts_at, :date, default: nil
    field :terminated_at, :date, default: nil
    field :ends_at, :date, default: nil

    timestamps()
  end

  @doc false
  def changeset(contract, attrs) do
    contract
    |> cast(attrs, [
      :club_id,
      :fee_id,
      :signed_at,
      :starts_at,
      :terminated_at,
      :ends_at],
      empty_values: ["", nil]
    )
    |> validate_required([:club_id, :fee_id, :signed_at, :starts_at])
  end
end
