defmodule Sportyweb.Organization.ClubEmail do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "club_emails" do

    field :club_id, :binary_id
    field :email_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(club_email, attrs) do
    club_email
    |> cast(attrs, [])
    |> validate_required([])
  end
end
