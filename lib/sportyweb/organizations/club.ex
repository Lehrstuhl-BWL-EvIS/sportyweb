defmodule Sportyweb.Organizations.Club do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clubs" do
    field :founding_date, :date
    field :name, :string
    field :reference_number, :string
    field :website_url, :string

    timestamps()
  end

  @doc false
  def changeset(club, attrs) do
    club
    |> cast(attrs, [:name, :reference_number, :website_url, :founding_date], empty_values: [])
    |> validate_required([:name, :founding_date])
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:website_url, max: 250)
  end
end
