defmodule SportywebWeb.AccessControl do

  use SportywebWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller
  import Ecto.Query

  alias Sportyweb.Repo
  alias Sportyweb.Organization
  alias Sportyweb.Organization.Club
  alias Sportyweb.AccessControl.UserClubRoles, as: UCR

  def load_authorized_clubs(user) do

    if is_sporty_web_admin(user) == true do
      Repo.all(Club)
    else
      query_user_clubs = from ucr in UCR,
      where: ucr.user_id == ^user.id,
      join: c in assoc(ucr, :club),
      select: c

    Repo.all(query_user_clubs)
    end
  end

  def require_super_user(conn, _ops) do

    role = conn.assigns.current_user.roles |> Enum.at(0)
    if role == "super_user" do
      conn
    else
      conn
      #|> put_flash(:error, "You have no permission to acces this page.")
      |> redirect(to: home_path(conn))
      |> halt()
    end
  end

  defp is_sporty_web_admin(user) do
    query = from ucr in UCR,
      where: ucr.user_id == ^user.id,
      join: cr in assoc(ucr, :clubrole),
      select: cr.name

      Enum.member?(Repo.all(query), "sportyweb_admin")
  end

  defp home_path(_conn), do: ~p"/"

end
