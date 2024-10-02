defmodule Sportyweb.RBAC.UserRole.UserClubRole do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Accounts.User
  alias Sportyweb.Organization.Club
  alias Sportyweb.RBAC.Role.ClubRole

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "userclubroles" do
    belongs_to :user, User
    belongs_to :club, Club
    belongs_to :clubrole, ClubRole

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_club_role, attrs) do
    user_club_role
    |> cast(attrs, [:user_id, :club_id, :clubrole_id])
    |> validate_required([:user_id, :club_id, :clubrole_id])
  end
end
