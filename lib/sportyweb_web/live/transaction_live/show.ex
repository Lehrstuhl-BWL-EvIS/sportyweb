defmodule SportywebWeb.TransactionLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounting
  alias Sportyweb.Accounting.Account

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :transactions)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    transaction = Accounting.get_transaction!(id, [:club, :contact, entry: [:account]])
    entries = Accounting.list_entries(id, [:account])
    financial_account = Accounting.get_financial_account(id, [:entry])

    {:noreply,
     socket
     |> assign(:page_title, "Transaktion: #{transaction.name}")
     |> assign(:transaction, transaction)
     |> assign(:club, transaction.club)
     |> assign(:financial_account, financial_account)
     |> stream(:entries, entries)}
  end
end
