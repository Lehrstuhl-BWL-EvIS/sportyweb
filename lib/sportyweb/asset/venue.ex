defmodule Sportyweb.Asset.Venue do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "venues" do
    belongs_to :club, Club

    field :name, :string
    field :reference_number, :string
    field :description, :string
    field :is_main, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(venue, attrs) do
    venue
    |> cast(attrs, [:club_id, :is_main, :name, :reference_number, :description], empty_values: [])
    |> validate_required([:club_id, :name])
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
  end
end
