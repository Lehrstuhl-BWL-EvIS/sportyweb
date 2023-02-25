defmodule SportywebWeb.UserDepartmentRoleLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.RBAC.UserRole

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:user_department_role, UserRole.get_user_department_role!(id))}
  end

  defp page_title(:show), do: "Show User department role"
end
