defmodule SportywebWeb.UserApplicationRoleLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.RBAC.UserRole

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :userapplicationroles, list_userapplicationroles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Userapplicationroles")
    |> assign(:user_application_role, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_application_role = UserRole.get_user_application_role!(id)
    {:ok, _} = UserRole.delete_user_application_role(user_application_role)

    {:noreply, assign(socket, :userapplicationroles, list_userapplicationroles())}
  end

  defp list_userapplicationroles do
    UserRole.list_userapplicationroles()
  end
end
