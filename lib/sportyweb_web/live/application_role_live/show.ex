defmodule SportywebWeb.ApplicationRoleLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.RBAC.Role

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:application_role, Role.get_application_role!(id))}
  end

  defp page_title(:show), do: "Show Application role"
  defp page_title(:edit), do: "Edit Application role"
end