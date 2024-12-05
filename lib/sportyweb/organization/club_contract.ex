defmodule Sportyweb.Organization.ClubContract do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization.Club

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "club_contracts" do
    belongs_to :club, Club
    belongs_to :contract, Contract

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(club_contract, attrs) do
    club_contract
    |> cast(attrs, [:club_id, :contract_id])
    |> validate_required([:club_id, :contract_id])
  end
end
