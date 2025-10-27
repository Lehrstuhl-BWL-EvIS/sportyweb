defmodule SportywebWeb.TransactionLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounting
  alias Sportyweb.Accounting.Transaction
  alias Sportyweb.Organization

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
    transaction = Accounting.get_transaction!(id, [:club, :contact])

    socket
    |> assign(:page_title, "Transaktion bearbeiten")
    |> assign(:transaction, transaction)
    |> assign(:club, transaction.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Transaktion erstellen")
    |> assign(:transaction, %Transaction{
      club_id: club.id,
      club: club
    })
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Accounting.get_transaction!(id)
    {:ok, _} = Accounting.delete_transaction(transaction)

    {:noreply,
     socket
     |> put_flash(:info, "Transaktion erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{transaction.club_id}/transactions")}
  end
end
