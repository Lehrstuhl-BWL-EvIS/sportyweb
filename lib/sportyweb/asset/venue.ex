defmodule Sportyweb.Asset.Venue do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "venues" do
    field :description, :string
    field :is_main, :boolean, default: false
    field :name, :string
    field :reference_number, :string
    field :club_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(venue, attrs) do
    venue
    |> cast(attrs, [:is_main, :name, :reference_number, :description])
    |> validate_required([:is_main, :name, :reference_number, :description])
  end
end
