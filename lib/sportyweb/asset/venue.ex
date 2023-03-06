defmodule Sportyweb.Asset.Venue do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Asset.VenuePostalAddress
  alias Sportyweb.Organization.Club
  alias Sportyweb.Polymorphic.PostalAddress

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "venues" do
    belongs_to :club, Club
    has_many :equipment, Equipment
    many_to_many :postal_addresses, PostalAddress, join_through: VenuePostalAddress

    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :description, :string, default: ""
    field :is_main, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(venue, attrs) do
    venue
    |> cast(attrs, [
      :club_id,
      :name,
      :reference_number,
      :description,
      :is_main
      ], empty_values: ["", nil])
    |> validate_required([:club_id, :name])
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> unique_constraint(
      :name,
      name: "venues_club_id_name_index",
      message: "Name bereits vergeben!")
  end
end
