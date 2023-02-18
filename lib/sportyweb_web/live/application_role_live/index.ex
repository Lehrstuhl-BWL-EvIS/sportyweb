defmodule SportywebWeb.ApplicationRoleLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.RBAC.Role
  alias Sportyweb.RBAC.Role.ApplicationRole

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :applicationroles, list_applicationroles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Application role")
    |> assign(:application_role, Role.get_application_role!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Application role")
    |> assign(:application_role, %ApplicationRole{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Applicationroles")
    |> assign(:application_role, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    application_role = Role.get_application_role!(id)
    {:ok, _} = Role.delete_application_role(application_role)

    {:noreply, assign(socket, :applicationroles, list_applicationroles())}
  end

  defp list_applicationroles do
    Role.list_applicationroles()
  end
end
