defmodule SportywebWeb.SubsidyLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Finance.Subsidy
  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :subsidies)}
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
    club = Organization.get_club!(club_id, [subsidies: :internal_events])

    socket
    |> assign(:page_title, "Zuschüsse")
    |> assign(:club, club)
    |> stream(:subsidies, club.subsidies)
  end
end
