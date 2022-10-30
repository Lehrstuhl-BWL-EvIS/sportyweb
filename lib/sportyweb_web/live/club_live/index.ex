defmodule SportywebWeb.ClubLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Organization.Club

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :clubs, list_clubs())}
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
    |> assign(:page_title, "Listing Clubs")
    |> assign(:club, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    club = Organization.get_club!(id)
    {:ok, _} = Organization.delete_club(club)

    {:noreply, assign(socket, :clubs, list_clubs())}
  end

  defp list_clubs do
    Organization.list_clubs()
  end
end
