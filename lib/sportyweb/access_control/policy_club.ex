defmodule Sportyweb.AccessControl.PolicyClub do

  import Ecto.Query

  alias Sportyweb.Repo
  alias Sportyweb.Organization.Club
  alias Sportyweb.AccessControl.UserClubRoles, as: UCR

  alias Sportyweb.AccessControl

  ### Member struct ###
  defmodule ClubMember do
    defstruct [:id, :email, :role]
  end

  ### LOAD/SHOW ###
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
      select: %ClubMember{id: ucr.id, email: u.email, role: cr.name}

    Repo.all(query_member_by_roles)
  end

  ### ACCESS ###
  def can?(_, :index, _), do: true

  def can?(user, :new, _params) do
    if AccessControl.is_sportyweb_admin(user), do: true, else: false
  end

  def can?(user, action, %{"id" => club_id}) when action in [:edit, "delete", :userrolemanagement] do
    if AccessControl.is_sportyweb_admin(user) || Enum.any?(AccessControl.has_club_role(user, club_id), fn r -> r in get_allowed_roles(action) end), do: true, else: false
  end

  def can?(user, :show, %{"id" => club_id}) do
    Enum.any?(load_authorized_clubs(user), fn club -> club.id == club_id end)
  end

  def can?(_, _, _), do: false

  defp get_allowed_roles(:edit), do: ["club_admin", "club_subadmin"]
  defp get_allowed_roles("delete"), do: ["club_admin"]
  defp get_allowed_roles(:userrolemanagement), do: ["club_admin"]

end
