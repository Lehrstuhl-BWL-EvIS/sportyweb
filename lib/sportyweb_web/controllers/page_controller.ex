defmodule SportywebWeb.PageController do
  use SportywebWeb, :controller

  def home(conn, _params) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: ~p"/clubs")
    else
      # The home page is often custom made,
      # so skip the default app layout.
      render(conn, :home, layout: false)
    end
  end
end
