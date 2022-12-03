defmodule SportywebWeb.ClubLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.AccessControl.PolicyClub

  alias Sportyweb.Organization

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if Enum.any?(PolicyClub.load_authorized_clubs(socket.assigns.current_user), fn x -> x.id == id end) do
      {:ok, socket}
    else
      {:ok, socket
        |> put_flash(:error, "No permission #{Atom.to_string(socket.assigns.action)} club")
        |> redirect(to: ~p"/clubs")}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    if PolicyClub.can?(socket.assigns.current_user, socket.assigns.live_action, %{"id" => id}) do
      {:noreply,
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:club, Organization.get_club!(id, [:departments]))}
    else
      {:noreply, socket
        |> put_flash(:error, "No permission #{Atom.to_string(socket.assigns.live_action)} club")
        |> redirect(to: ~p"/clubs/#{id}")}
    end
  end

  defp page_title(:show), do: "Show Club"
  defp page_title(:edit), do: "Edit Club"
end
