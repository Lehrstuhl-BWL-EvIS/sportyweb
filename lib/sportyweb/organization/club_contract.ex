defmodule Sportyweb.Organization.ClubContract do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "club_contracts" do

    field :club_id, :binary_id
    field :contract_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(club_contract, attrs) do
    club_contract
    |> cast(attrs, [])
    |> validate_required([])
  end
end
