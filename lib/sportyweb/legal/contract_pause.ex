defmodule Sportyweb.Legal.ContractPause do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.Contract

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contract_pauses" do
    belongs_to :contract, Contract

    field :starts_at, :date, default: nil
    field :ends_at, :date, default: nil

    timestamps()
  end

  @doc false
  def changeset(contract_pause, attrs) do
    contract_pause
    |> cast(attrs, [:contract_id, :starts_at, :ends_at], empty_values: ["", nil])
    |> validate_required([:contract_id, :starts_at, :ends_at])
  end
end
