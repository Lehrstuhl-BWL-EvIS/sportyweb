defmodule SportywebWeb.ClubLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.AccessControl.PolicyClub

  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
    socket
    |> assign(:club_navigation_current_item, :dashboard)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    if PolicyClub.can?(socket.assigns.current_user, socket.assigns.live_action, id) do
      {:noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:club, Organization.get_club!(id, [:departments]))}
    else
      {:noreply, socket
        |> put_flash(:error, "No permission to #{Atom.to_string(socket.assigns.live_action)} club")
        |> redirect(to: action_route(socket.assigns.live_action, id))}
    end
  end

  defp page_title(:show), do: "Show Club"
  defp page_title(:edit), do: "Edit Club"

  defp action_route(:show, _ ), do:  ~p"/clubs"
  defp action_route(:edit, id), do:  ~p"/clubs/#{id}"
end
