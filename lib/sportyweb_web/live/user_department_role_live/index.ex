defmodule SportywebWeb.UserDepartmentRoleLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.RBAC.UserRole
  alias Sportyweb.RBAC.UserRole.UserDepartmentRole

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :userdepartmentroles, list_userdepartmentroles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User department role")
    |> assign(:user_department_role, UserRole.get_user_department_role!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User department role")
    |> assign(:user_department_role, %UserDepartmentRole{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Userdepartmentroles")
    |> assign(:user_department_role, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user_department_role = UserRole.get_user_department_role!(id)
    {:ok, _} = UserRole.delete_user_department_role(user_department_role)

    {:noreply, assign(socket, :userdepartmentroles, list_userdepartmentroles())}
  end

  defp list_userdepartmentroles do
    UserRole.list_userdepartmentroles()
  end
end
