defmodule SportywebWeb.ForecastLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Finance
  alias Sportyweb.Organization
  alias Sportyweb.Personal

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :forecasts)}
  end

  @impl true
  def handle_params(%{"club_id" => club_id, "start_date" => start_date, "end_date" => end_date} = params, _url, socket) do
    club = Organization.get_club!(club_id)

    {:noreply,
     socket
     |> assign(:start_date, start_date)
     |> assign(:end_date, end_date)
     |> assign(:club, club)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show_contacts_all, _params) do
    socket
    |> assign(:page_title, "Vorschau: Alle Mitglieder")
  end

  defp apply_action(socket, :show_contacts_single, %{"contact_id" => contact_id}) do
    contact = Personal.get_contact!(contact_id)

    socket
    |> assign(:page_title, "Vorschau Mitglied: - #{contact.name}")
  end

  defp apply_action(socket, :show_subsidies_all, _params) do
    socket
    |> assign(:page_title, "Vorschau: Alle Zuschüsse")
  end

  defp apply_action(socket, :show_subsidies_single, %{"subsidy_id" => subsidy_id}) do
    subsidy = Finance.get_subsidy!(subsidy_id)

    socket
    |> assign(:page_title, "Vorschau Zuschuss: - #{subsidy.name}")
  end
end
