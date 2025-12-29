defmodule SportywebWeb.IncomeStatementLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounting
  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :income_statements)}
  end

  @impl true
  def handle_params(
        %{
          "club_id" => club_id,
          "start_date" => start_date_string,
          "end_date" => end_date_string
        } = params,
        _url,
        socket
      ) do
    club = Organization.get_club!(club_id)
    {:ok, start_date} = Date.from_iso8601(start_date_string)
    {:ok, end_date} = Date.from_iso8601(end_date_string)

    {:noreply,
     socket
     |> assign(:start_date, start_date)
     |> assign(:end_date, end_date)
     |> assign(:club, club)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    income_statement =
      Accounting.determine_income_statement(
        socket.assigns.start_date,
        socket.assigns.end_date,
        socket.assigns.club.id
      )

    socket
    |> assign(:page_title, "EÜR")
    |> stream(:income_statement, income_statement)
  end
end
