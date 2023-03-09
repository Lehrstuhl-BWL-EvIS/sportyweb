defmodule Sportyweb.Asset.VenueEmail do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Venue
  alias Sportyweb.Polymorphic.Email

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "venue_emails" do
    belongs_to :venue, Venue
    belongs_to :email, Email

    timestamps()
  end

  @doc false
  def changeset(venue_email, attrs) do
    venue_email
    |> cast(attrs, [:venue_id, :email_id])
    |> validate_required([:venue_id, :email_id])
    |> unique_constraint(:email_id, name: "venue_emails_email_id_index")
  end
end
