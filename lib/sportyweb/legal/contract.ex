defmodule Sportyweb.Legal.Contract do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contracts" do
    field :ends_at, :date
    field :signed_at, :date
    field :starts_at, :date
    field :terminated_at, :date
    field :club_id, :binary_id
    field :fee_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(contract, attrs) do
    contract
    |> cast(attrs, [:signed_at, :starts_at, :terminated_at, :ends_at])
    |> validate_required([:signed_at, :starts_at, :terminated_at, :ends_at])
  end
end
