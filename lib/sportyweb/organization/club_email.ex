defmodule Sportyweb.Organization.ClubEmail do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Polymorphic.Email

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "club_emails" do
    belongs_to :club, Club
    belongs_to :email, Email

    timestamps()
  end

  @doc false
  def changeset(club_email, attrs) do
    club_email
    |> cast(attrs, [:club_id, :email_id])
    |> validate_required([:club_id, :email_id])
    |> unique_constraint(:email_id, name: "club_emails_email_id_index")
  end
end
