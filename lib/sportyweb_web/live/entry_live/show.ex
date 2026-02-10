defmodule SportywebWeb.EntryLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounting
  alias Sportyweb.Accounting.Account

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :transactions)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    entry = Accounting.get_entry!(id, [:account, transaction: [:club]])

    {:noreply,
     socket
     |> assign(:page_title, "Buchung")
     |> assign(:entry, entry)
     |> assign(:transaction, entry.transaction)
     |> assign(:club, entry.transaction.club)}
  end

  defp show_edit_button?(account_number) do
    account_number = String.to_integer(account_number)
    account_number < 15_500 || account_number > 18_899
  end
end
