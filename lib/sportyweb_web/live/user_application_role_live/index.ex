defmodule SportywebWeb.UserApplicationRoleLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.AccessControl
  alias Sportyweb.AccessControl.UserApplicationRole

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :userapplicationroles, list_userapplicationroles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User application role")
    |> assign(:user_application_role, AccessControl.get_user_application_role!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User application role")
    |> assign(:user_application_role, %UserApplicationRole{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Userapplicationroles")
    |> assign(:user_application_role, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_application_role = AccessControl.get_user_application_role!(id)
    {:ok, _} = AccessControl.delete_user_application_role(user_application_role)

    {:noreply, assign(socket, :userapplicationroles, list_userapplicationroles())}
  end

  defp list_userapplicationroles do
    AccessControl.list_userapplicationroles_data()
  end
end
