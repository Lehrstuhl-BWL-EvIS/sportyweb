defmodule SportywebWeb.TransactionLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounting
  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :transactions)}
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
    transactions = Accounting.list_transactions(club_id, contract: :contact)

    socket
    |> assign(:page_title, "Transaktionen")
    |> assign(:club, club)
    |> stream(:transactions, transactions)
  end
end
