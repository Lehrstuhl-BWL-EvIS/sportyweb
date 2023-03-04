defmodule Sportyweb.Legal.ContractPause do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contract_pauses" do
    field :ends_at, :date
    field :starts_at, :date
    field :contract_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(contract_pause, attrs) do
    contract_pause
    |> cast(attrs, [:starts_at, :ends_at])
    |> validate_required([:starts_at, :ends_at])
  end
end
