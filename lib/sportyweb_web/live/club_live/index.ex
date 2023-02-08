defmodule SportywebWeb.ClubLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.AccessControl.PolicyClub

  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :clubs, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Club")
    |> assign(:club, Organization.get_club!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Club")
    |> assign(:club, %Club{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:clubs, PolicyClub.load_authorized_clubs(socket.assigns.current_user))
    |> assign(:page_title, "Alle Vereine")
    |> assign(:club, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    if PolicyClub.can?(socket.assigns.current_user, "delete", id) do
      club = Organization.get_club!(id)
      {:ok, _} = Organization.delete_club(club)

      {:noreply,
        socket
        |> put_flash(:info, "Club deleted successfully")
        |> assign(:clubs, PolicyClub.load_authorized_clubs(socket.assigns.current_user))}
    else
      {:noreply,
        socket
        |> put_flash(:error, "No permission to delete club")
        |> assign(:clubs, PolicyClub.load_authorized_clubs(socket.assigns.current_user))}
    end
  end
end
