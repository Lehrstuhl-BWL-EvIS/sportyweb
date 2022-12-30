defmodule SportywebWeb.ClubLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Organization.Club

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.ClubLive.FormComponent}
        id={@club.id || :new}
        title={@page_title}
        action={@live_action}
        club={@club}
        navigate={if @club.id, do: ~p"/clubs/#{@club}", else: ~p"/clubs"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
    socket
    |> assign(:club_navigation_id, :dashboard)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Verein bearbeiten")
    |> assign(:club, Organization.get_club!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Verein erstellen")
    |> assign(:club, %Club{})
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    club = Organization.get_club!(id)
    {:ok, _} = Organization.delete_club(club)

    {:noreply,
    socket
    |> put_flash(:info, "Verein erfolgreich gelöscht")
    |> push_navigate(to: "/clubs")}
  end
end
