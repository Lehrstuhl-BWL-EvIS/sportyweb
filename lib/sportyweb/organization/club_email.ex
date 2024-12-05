defmodule Sportyweb.Organization.ClubEmail do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Club
  alias Sportyweb.Polymorphic.Email

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "club_emails" do
    belongs_to :club, Club
    belongs_to :email, Email

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(club_email, attrs) do
    club_email
    |> cast(attrs, [:club_id, :email_id])
    |> validate_required([:club_id, :email_id])
    |> unique_constraint(:email_id, name: "club_emails_email_id_index")
  end
end
