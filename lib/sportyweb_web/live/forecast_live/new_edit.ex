defmodule SportywebWeb.ForecastLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Finance.Forecast
  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.ForecastLive.FormComponent}
        id={:new}
        title={@page_title}
        action={@live_action}
        forecast={@forecast}
        club={@club}
        navigate={~p"/clubs/#{@club}/forecasts"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :forecasts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)
    today = Date.utc_today()

    socket
    |> assign(:page_title, "Prognose erstellen")
    |> assign(:forecast, %Forecast{
      start_date: today,
      end_date: today}
    )
    |> assign(:club, club)
  end
end
