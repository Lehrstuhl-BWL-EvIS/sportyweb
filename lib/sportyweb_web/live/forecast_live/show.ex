defmodule SportywebWeb.ForecastLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounting
  alias Sportyweb.Finance
  alias Sportyweb.Legal
  alias Sportyweb.Organization
  alias Sportyweb.Personal

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :forecasts)}
  end

  @impl true
  def handle_params(%{
    "club_id" => club_id,
    "start_date" => start_date_str,
    "end_date" => end_date_str} = params, _url, socket) do
    club = Organization.get_club!(club_id)
    {:ok, start_date} = Date.from_iso8601(start_date_str)
    {:ok, end_date}   = Date.from_iso8601(end_date_str)

    {:noreply,
     socket
     |> assign(:start_date, start_date)
     |> assign(:end_date, end_date)
     |> assign(:club, club)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show_contacts_all, _params) do
    {transactions, transactions_amount_sum} =
      Accounting.forecast_transactions(:fee, all_contracts(socket), socket.assigns.start_date, socket.assigns.end_date)

    socket
    |> assign(:page_title, "Vorschau: Alle Kontakte")
    |> assign(:transactions_amount_sum, transactions_amount_sum)
    |> stream(:transactions, transactions)
  end

  defp apply_action(socket, :show_contacts_single, %{"contact_id" => contact_id}) do
    contact =
      Personal.get_contact!(contact_id, [contracts: [:contact, fee: [:internal_events, subsidy: :internal_events]]])
    {transactions, transactions_amount_sum} =
      Accounting.forecast_transactions(:fee, contact.contracts, socket.assigns.start_date, socket.assigns.end_date)

    socket
    |> assign(:page_title, "Vorschau Kontakt: #{contact.name}")
    |> assign(:transactions_amount_sum, transactions_amount_sum)
    |> stream(:transactions, transactions)
  end

  defp apply_action(socket, :show_subsidies_all, _params) do
    {transactions, transactions_amount_sum} =
      Accounting.forecast_transactions(:subsidy, all_contracts(socket), socket.assigns.start_date, socket.assigns.end_date)

    socket
    |> assign(:page_title, "Vorschau: Alle Zuschüsse")
    |> assign(:transactions_amount_sum, transactions_amount_sum)
    |> stream(:transactions, transactions)
  end

  defp apply_action(socket, :show_subsidies_single, %{"subsidy_id" => subsidy_id}) do
    # Preloading the data this way might seem inefficent, but it enables a uniform handling of the transaction generation.
    # And because there are no subsequent database calls it is actually pretty fast.
    subsidy =
      Finance.get_subsidy!(subsidy_id, [fees: [contracts: [:contact, fee: [:internal_events, subsidy: :internal_events]]]])

    contracts =
      subsidy.fees
      |> Enum.map(fn fee -> fee.contracts end)
      |> List.flatten()

    {transactions, transactions_amount_sum} =
      Accounting.forecast_transactions(:subsidy, contracts, socket.assigns.start_date, socket.assigns.end_date)

    socket
    |> assign(:page_title, "Vorschau Zuschuss: #{subsidy.name}")
    |> assign(:transactions_amount_sum, transactions_amount_sum)
    |> stream(:transactions, transactions)
  end

  defp all_contracts(socket) do
    Legal.list_contracts(socket.assigns.club.id, [:contact, fee: [:internal_events, subsidy: :internal_events]])
  end
end
