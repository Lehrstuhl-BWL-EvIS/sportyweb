defmodule Sportyweb.AccessControl.UserClubRole do
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
    belongs_to :clubrole, ClubRole, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(user_club_role, attrs) do
    user_club_role
    |> cast(attrs, [])
    |> validate_required([])
  end

  def managechanges(user_club_role, attr) do
    user_club_role
    |> change(attr)
    |> validate_required([:user_id, :club_id, :clubrole_id])
  end

end
