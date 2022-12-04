defmodule SportywebWeb.ClubLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.AccessControl.PolicyClub

  alias Sportyweb.Organization
  alias Sportyweb.Organization.Club

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :clubs, PolicyClub.load_authorized_clubs(socket.assigns.current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    if PolicyClub.can?(socket.assigns.current_user, socket.assigns.live_action, params) do
      {:noreply, apply_action(socket, socket.assigns.live_action, params)}
    else
      {:noreply,
        socket
        |> put_flash(:error, "No permission to #{Atom.to_string(socket.assigns.live_action)} club")
        |> redirect(to: ~p"/clubs")}
    end
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
    if PolicyClub.can?(socket.assigns.current_user, "delete", %{"id" => id}) do
      club = Organization.get_club!(id)
      {:ok, _} = Organization.delete_club(club)

      {:noreply, assign(socket, :clubs, PolicyClub.load_authorized_clubs(socket.assigns.current_user))}
    else
      {:noreply,
        socket
        |> put_flash(:error, "No permission to delete club")
        |> assign(:clubs, PolicyClub.load_authorized_clubs(socket.assigns.current_user))}
    end
  end
end
