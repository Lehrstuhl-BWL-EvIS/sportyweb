defmodule SportywebWeb.EquipmentLive.Index do
  use SportywebWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    """
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

  defp apply_action(socket, :index, %{"location_id" => location_id}) do
    socket
    |> redirect(to: "/locations/#{location_id}")
  end
end
