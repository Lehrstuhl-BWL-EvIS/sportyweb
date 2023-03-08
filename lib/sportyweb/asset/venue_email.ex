defmodule Sportyweb.Asset.VenueEmail do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "venue_emails" do

    field :venue_id, :binary_id
    field :email_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(venue_email, attrs) do
    venue_email
    |> cast(attrs, [])
    |> validate_required([])
  end
end
