defmodule Sportyweb.AccessControl.UserClubRoles do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Accounts.User
  alias Sportyweb.AccessControl.ClubRole
  alias Sportyweb.Organization.Club

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "userclubroles" do
    belongs_to :user, User
    belongs_to :club, Club
    belongs_to :clubrole, ClubRole

    timestamps()
  end

  @doc false
  def changeset(user_club_roles, attrs) do
    user_club_roles
    |> cast(attrs, [])
    |> validate_required([])
  end
end
