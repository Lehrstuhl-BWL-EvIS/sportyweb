defmodule SportywebWeb.ClubLive.Index do
  use SportywebWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    #{:ok, stream(socket, :clubs, Organization.list_clubs())}
    #{:ok, stream(socket, :clubs, [])}
    {:ok, socket}

  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params), do: socket
end
