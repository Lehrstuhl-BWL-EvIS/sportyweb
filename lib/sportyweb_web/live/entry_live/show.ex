defmodule SportywebWeb.EntryLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounting

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :entries)}
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
    account_number < 15500 || account_number > 18899
  end
end
