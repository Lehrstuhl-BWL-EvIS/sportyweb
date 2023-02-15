defmodule SportywebWeb.EquipmentLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:equipment, Asset.get_equipment!(id))}
  end

  defp page_title(:show), do: "Show Equipment"
  defp page_title(:edit), do: "Edit Equipment"
end
