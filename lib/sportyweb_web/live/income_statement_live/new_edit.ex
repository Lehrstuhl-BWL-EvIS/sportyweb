defmodule SportywebWeb.IncomeStatementLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounting.IncomeStatement
  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.IncomeStatementLive.FormComponent}
        id={:new}
        title={@page_title}
        action={@live_action}
        income_statement={@income_statement}
        club={@club}
        navigate={~p"/clubs/#{@club}/income_statements"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :income_statements)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)
    today = Date.utc_today()

    socket
    |> assign(:page_title, "Einnahmenüberschussrechnung (EÜR) erstellen")
    |> assign(:income_statement, %IncomeStatement{
      start_date: today,
      end_date: today
    })
    |> assign(:club, club)
  end
end
