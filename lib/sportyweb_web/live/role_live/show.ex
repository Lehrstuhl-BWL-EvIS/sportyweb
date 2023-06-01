defmodule SportywebWeb.RoleLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.RBAC.Role.RolePermissionMatrix, as: RPM

  defmodule RoleInfo, do: defstruct [:id, :name, :info]

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :authorization)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"club_id" => club_id}) do
    [clubroles, departmentroles] = [:club, :department]
    |> Enum.map(&(RPM.role_permission_matrix(&1)))
    |> Enum.map(&(Keyword.values(&1)))
    |> Enum.map(&(Enum.map(&1, fn x -> %RoleInfo{id: 0, name: Map.get(x, :Name), info: Map.get(x, :Info)} end)))

    socket
    |> assign(:club_id, club_id)
    |> assign(:clubroles, clubroles)
    |> assign(:departmentroles, departmentroles)
  end
end
