defmodule SportywebWeb.FeeLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal
  alias Sportyweb.Organization

  @impl true
  def mount(%{"club_id" => club_id}, _session, socket) do
    {:ok,
     socket
     |> assign(:club_navigation_current_item, :finances)
     |> stream(:fees, Legal.list_fees(club_id))}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index_root, _params) do
    socket
    |> redirect(to: "/clubs")
  end

  defp apply_action(socket, :index, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Allgemeine Gebühren")
    |> assign(:club, club)
  end
end
