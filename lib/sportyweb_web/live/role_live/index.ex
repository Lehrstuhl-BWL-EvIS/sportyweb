defmodule SportywebWeb.RoleLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.RBAC

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :authorization)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"club_id" => club_id} = params) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Listing Roles")
    |> assign(:club, club)
    |> assign(:roles, list_roles(params))
  end

  defp list_roles(%{"club_id" => club_id}) do
    RBAC.list_roles(club_id)
  end
end
