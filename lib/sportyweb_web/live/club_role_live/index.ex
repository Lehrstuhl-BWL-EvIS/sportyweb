defmodule SportywebWeb.ClubRoleLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.AccessControl
  alias Sportyweb.AccessControl.ClubRole

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :clubroles, list_clubroles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Club role")
    |> assign(:club_role, AccessControl.get_club_role!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Club role")
    |> assign(:club_role, %ClubRole{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Clubroles")
    |> assign(:club_role, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    club_role = AccessControl.get_club_role!(id)
    {:ok, _} = AccessControl.delete_club_role(club_role)

    {:noreply, assign(socket, :clubroles, list_clubroles())}
  end

  defp list_clubroles do
    AccessControl.list_clubroles()
  end
end
