defmodule SportywebWeb.AccessControl do

  ### DEPRECATE ###
  use SportywebWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

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

  defp home_path(_conn), do: ~p"/"

end
