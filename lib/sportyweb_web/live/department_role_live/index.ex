defmodule SportywebWeb.DepartmentRoleLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.RBAC.Role
  alias Sportyweb.RBAC.Role.DepartmentRole

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :departmentroles, list_departmentroles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Department role")
    |> assign(:department_role, Role.get_department_role!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Department role")
    |> assign(:department_role, %DepartmentRole{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Departmentroles")
    |> assign(:department_role, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    department_role = Role.get_department_role!(id)
    {:ok, _} = Role.delete_department_role(department_role)

    {:noreply, assign(socket, :departmentroles, list_departmentroles())}
  end

  defp list_departmentroles do
    Role.list_departmentroles()
  end
end
