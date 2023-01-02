defmodule Sportyweb.AccessControl.PolicyClub do

  import Ecto.Query

  alias Sportyweb.Repo
  alias Sportyweb.Accounts.User
  alias Sportyweb.Organization.Club

  alias Sportyweb.AccessControl
  alias Sportyweb.AccessControl.PolicyApplication
  alias Sportyweb.AccessControl.UserClubRole, as: UCR
  alias Sportyweb.AccessControl.RolePermissionMatrix, as: RPM

  ### ROLE-PERMISSION-MATRIX ###
  def role_permission_matrix, do: RPM.role_permission_matrix(:club)

  def get_club_roles_all, do: Keyword.keys(role_permission_matrix()) |> Enum.map(&( Atom.to_string(&1)))
  def get_club_roles_for_administration(user, club_id) do
    role = if PolicyApplication.is_sportyweb_admin(user) do
      get_club_roles_all() |> Enum.at(0)
    else
      has_club_role(user, club_id) |> Enum.at(0)
    end

    get_club_roles_all()
    |> Enum.drop_while(&(&1 != role))
  end

  ### RESTRICTED QUERIES ###
  def load_authorized_clubs(user) do
    if PolicyApplication.is_sportyweb_admin(user) == true do
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
    if PolicyApplication.is_sportyweb_admin(user), do: true, else: false
  end
  def can?(user, action, %{"id" => club_id}), do: can?(user, action, club_id)
  def can?(user, action, club_id) when action in [:new, :edit, "delete", :show, :userrolemanagement] do
    if PolicyApplication.is_sportyweb_admin(user) ||
       user
       |> has_club_role(club_id)
       |> Enum.map(fn role -> Keyword.get(role_permission_matrix(), String.to_atom(role)) end)
       |> List.flatten()
       |> Enum.uniq()
       |> Enum.member?(action),
    do: true, else: false
  end
  def can?(_, _, _), do: false

  ### HELPER FUNCTIONS ###
  def ucr_has_role?(ucr_id, role_name) do
    AccessControl.get_user_club_role!(ucr_id).clubrole_id == AccessControl.get_club_role_by_name(role_name).id
  end

  def ucr_change_role(ucrchanges) do
    ucrchanges
    |> Enum.map(fn {ucr_id, role_name} ->
        ucr_id
        |> AccessControl.get_user_club_role!()
        |> AccessControl.manage_user_club_role(%{clubrole_id: AccessControl.get_club_role_by_name(role_name).id})
      end)
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.member?(:error)
  end

  def has_club_role(%User{id: user_id}, club_id) do
    query = from ucr in UCR,
      where: ucr.user_id == ^user_id and ucr.club_id == ^club_id,
      join: cr in assoc(ucr, :clubrole),
      select: cr.name

    Repo.all(query)
  end
end
