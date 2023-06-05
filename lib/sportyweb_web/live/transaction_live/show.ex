defmodule SportywebWeb.TransactionLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounting

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :transactions)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    transaction = Accounting.get_transaction!(id, [:club])

    {:noreply,
     socket
     |> assign(:page_title, "Transaktion: #{transaction.name}")
     |> assign(:transaction, transaction)
     |> assign(:club, transaction.club)}
  end
end
