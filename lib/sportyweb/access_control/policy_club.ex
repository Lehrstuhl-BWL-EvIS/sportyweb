defmodule Sportyweb.AccessControl.PolicyClub do

  import Ecto.Query

  alias Sportyweb.Repo
  alias Sportyweb.Organization.Club
  alias Sportyweb.AccessControl.UserClubRoles, as: UCR

  alias Sportyweb.AccessControl

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

  ### ACCESS ###
  def can?(_, :index, _), do: true

  def can?(user, :new, _params) do
    if AccessControl.is_sportyweb_admin(user), do: true, else: false
  end

  def can?(user, :edit, %{"id" => club_id}) do
    allowed_roles = ["club_admin", "club_subadmin"]
    if AccessControl.is_sportyweb_admin(user) || Enum.any?(AccessControl.has_club_role(user, club_id), fn r -> r in allowed_roles end), do: true, else: false
  end

  def can?(user, "delete", club_id) do
    allowed_roles = ["club_admin"]
    if AccessControl.is_sportyweb_admin(user) || Enum.any?(AccessControl.has_club_role(user, club_id), fn r -> r in allowed_roles end), do: true, else: false
  end

  def can?(user, :show, %{"id" => club_id}) do
    Enum.any?(load_authorized_clubs(user), fn club -> club.id == club_id end)
  end

  def can?(_, _, _), do: false

end
