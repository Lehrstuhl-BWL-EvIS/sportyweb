defmodule Sportyweb.Organization.ClubFinancialData do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "club_financial_data" do

    field :club_id, :binary_id
    field :financial_data_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(club_financial_data, attrs) do
    club_financial_data
    |> cast(attrs, [])
    |> validate_required([])
  end
end
