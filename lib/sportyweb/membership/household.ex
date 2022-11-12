defmodule Sportyweb.Membership.Household do
  use Ecto.Schema
  import Ecto.Changeset

  schema "households" do
    field :identifier, :string

    timestamps()
  end

  @doc false
  def changeset(household, attrs) do
    household
    |> cast(attrs, [:identifier])
    |> validate_required([:identifier])
    |> unique_constraint(:identifier)
  end
end
