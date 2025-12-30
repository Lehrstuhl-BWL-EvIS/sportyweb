defmodule SportywebWeb.EntryLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounting
  alias Sportyweb.Accounting.Entry

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.EntryLive.FormComponent}
        id={@entry.id || :new}
        title={@page_title}
        action={@live_action}
        entry={@entry}
        navigate={
          if @entry.id,
            do: ~p"/transactions/#{@transaction}/entries/#{@entry}",
            else: ~p"/transactions/#{@transaction}"
        }
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :transactions)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    entry = Accounting.get_entry!(id, [:account, transaction: [:club]])

    socket
    |> assign(:page_title, "Buchung bearbeiten")
    |> assign(:entry, entry)
    |> assign(:transaction, entry.transaction)
    |> assign(:club, entry.transaction.club)
  end

  defp apply_action(socket, :new, %{"transaction_id" => transaction_id}) do
    transaction = Accounting.get_transaction!(transaction_id, [:club])

    socket
    |> assign(:page_title, "Buchung erstellen")
    |> assign(:entry, %Entry{
      transaction_id: transaction.id,
      transaction: transaction
    })
    |> assign(:club, transaction.club)
    |> assign(:transaction, transaction)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    entry = Accounting.get_entry!(id)
    {:ok, _} = Accounting.delete_entry_and_update_account_balance(entry)

    {:noreply,
     socket
     |> put_flash(:info, "Buchung erfolgreich gelöscht")
     |> push_navigate(to: "/transactions/#{entry.transaction_id}")}
  end
end
