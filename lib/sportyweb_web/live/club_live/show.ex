defmodule SportywebWeb.ClubLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :dashboard)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    club =
      Organization.get_club!(id, [:departments, :emails, :financial_data, :notes, :phones, :venue])

    {:noreply,
     socket
     |> assign(:page_title, "Verein: #{club.name}")
     |> assign(:club, club)}
  end
end
