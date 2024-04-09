defmodule SportywebWeb.TransactionLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounting

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.TransactionLive.FormComponent}
        id={@transaction.id || :new}
        title={@page_title}
        action={@live_action}
        transaction={@transaction}
        navigate={
          if @transaction.id,
            do: ~p"/transactions/#{@transaction}",
            else: ~p"/clubs/#{@club}/transactions"
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
    transaction = Accounting.get_transaction!(id, contract: [:club, :contact])

    socket
    |> assign(:page_title, "Transaktion bearbeiten")
    |> assign(:transaction, transaction)
    |> assign(:club, transaction.contract.club)
  end

  # There is currently no function for :new because transactions are
  # exclusively generated automatically to avoid possible manual errors.
  # Because transactions can't be created, they consequently can't be deleted.
end
