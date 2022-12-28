defmodule Sportyweb.AccessControl.PolicyClub do

  import Ecto.Query

  alias Sportyweb.Repo
  alias Sportyweb.Organization.Club
  alias Sportyweb.AccessControl.UserClubRoles, as: UCR

  alias Sportyweb.AccessControl

  ### ROLES-PERMISSIONS-MATRIX ###
  def role_permission_matrix do
    [
      sportyweb_admin:         [:index, :new, :edit, "delete", :show, :userrolemanagement ],
      club_admin:              [:index,  nil, :edit, "delete", :show, :userrolemanagement ],
      club_subadmin:           [:index,  nil, :edit,      nil, :show, :userrolemanagement ],
      club_readwrite_member:   [:index,  nil, :edit,      nil, :show,                 nil ],
      club_member:             [:index,  nil,   nil,      nil, :show,                 nil ]
    ]
  end

  def get_club_roles_all, do: Keyword.keys(role_permission_matrix()) |> Enum.map(&( Atom.to_string(&1)))
  def get_club_roles_for_administration(user, club_id) do
    role = if AccessControl.is_sportyweb_admin(user) do
      get_club_roles_all() |> Enum.at(1)
    else
      AccessControl.has_club_role(user, club_id) |> Enum.at(0)
    end

    get_club_roles_all()
    |> Enum.drop_while(&(&1 != role))
  end

  ### RESTRICTED QUERIES ###
  def load_authorized_clubs(user) do
    if AccessControl.is_sportyweb_admin(user) == true do
      Repo.all(Club)
    else
      query_user_clubs = from ucr in UCR,
        where: ucr.user_id == ^user.id,
        join: c in assoc(ucr, :club),
        select: c

      Repo.all(query_user_clubs)
    end
  end

  def get_club_members_and_their_roles(club_id) do
    query_member_by_roles = from ucr in UCR,
      where: ucr.club_id == ^club_id,
      join: u in assoc(ucr, :user),
      join: cr in assoc(ucr, :clubrole),
      preload: [:user, :clubrole]

    Repo.all(query_member_by_roles)
  end

  def get_club_name_by_id(club_id) do
    query_clubname = from ucr in UCR,
      where: ucr.club_id == ^club_id,
      join: c in assoc(ucr, :club),
      select: c.name

    Repo.all(query_clubname) |> Enum.at(0)
  end

  ### ACCESS POLICY ###
  def can?(_user, :index, _params), do: true
  def can?(user, :new, _params) do
    if AccessControl.is_sportyweb_admin(user), do: true, else: false
  end
  def can?(user, action, %{"id" => club_id}) when action in [:new, :edit, "delete", :show, :userrolemanagement] do
    if AccessControl.is_sportyweb_admin(user) ||
       user
       |> AccessControl.has_club_role(club_id)
       |> Enum.map(fn role -> Keyword.get(role_permission_matrix(), String.to_atom(role)) end)
       |> List.flatten()
       |> Enum.uniq()
       |> Enum.member?(action),
    do: true, else: false
  end
  def can?(_, _, _), do: false

  ### HELPER FUNCTIONS ###
  def ucr_has_role?(ucr_id, role_name) do
    AccessControl.get_user_club_roles!(ucr_id).clubrole_id == AccessControl.get_club_role_by_name(role_name).id
  end

  def ucr_change_role(ucrchanges) do
    ucrchanges
    |> Enum.map(fn {ucr_id, role_name} ->
        ucr_id
        |> AccessControl.get_user_club_roles!()
        |> AccessControl.manage_user_club_roles(%{clubrole_id: AccessControl.get_club_role_by_name(role_name).id})
      end)
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.member?(:error)
  end

end
