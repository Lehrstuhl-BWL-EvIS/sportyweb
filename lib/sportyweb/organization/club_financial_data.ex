defmodule Sportyweb.Organization.ClubFinancialData do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Polymorphic.FinancialData

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "club_financial_data" do
    belongs_to :club, Club
    belongs_to :financial_data, FinancialData

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(club_financial_data, attrs) do
    club_financial_data
    |> cast(attrs, [:club_id, :financial_data_id])
    |> validate_required([:club_id, :financial_data_id])
    |> unique_constraint(:financial_data_id, name: "club_financial_data_financial_data_id_index")
  end
end
