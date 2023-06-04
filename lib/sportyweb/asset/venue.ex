defmodule Sportyweb.Asset.Venue do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Asset.VenueEmail
  alias Sportyweb.Asset.VenueFee
  alias Sportyweb.Asset.VenueNote
  alias Sportyweb.Asset.VenuePhone
  alias Sportyweb.Asset.VenuePostalAddress
  alias Sportyweb.Finance.Fee
  alias Sportyweb.Organization.Club
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone
  alias Sportyweb.Polymorphic.PostalAddress

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "venues" do
    belongs_to :club, Club
    has_many :equipment, Equipment, preload_order: [asc: :name]
    many_to_many :emails, Email, join_through: VenueEmail
    many_to_many :fees, Fee, join_through: VenueFee
    many_to_many :notes, Note, join_through: VenueNote
    many_to_many :phones, Phone, join_through: VenuePhone
    many_to_many :postal_addresses, PostalAddress, join_through: VenuePostalAddress

    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :description, :string, default: ""

    timestamps()
  end

  @doc false
  def changeset(venue, attrs) do
    venue
    |> cast(attrs, [
      :club_id,
      :name,
      :reference_number,
      :description],
      empty_values: ["", nil]
    )
    |> cast_assoc(:emails, required: true)
    |> cast_assoc(:notes, required: true)
    |> cast_assoc(:phones, required: true)
    |> cast_assoc(:postal_addresses, required: true)
    |> validate_required([:club_id, :name])
    |> update_change(:name, &String.trim/1)
    |> update_change(:reference_number, &String.trim/1)
    |> update_change(:description, &String.trim/1)
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> unique_constraint(
      :name,
      name: "venues_club_id_name_index",
      message: "Name bereits vergeben!"
    )
  end
end
