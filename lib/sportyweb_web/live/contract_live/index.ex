defmodule SportywebWeb.ContractLive.Index do
  use SportywebWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div>Currently not in use</div>
    """
  end

  @impl true
  def mount(%{"club_id" => _club_id}, _session, socket) do
    {:ok,
     socket
     |> assign(:club_navigation_current_item, :fees)}
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
end
