defmodule SportywebWeb.AccountLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounting
  alias Sportyweb.Accounting.Account
  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.AccountLive.FormComponent}
        id={@account.id || :new}
        title={@page_title}
        action={@live_action}
        account={@account}
        activate_opening_balance={@activate_opening_balance}
        navigate={
          if @account.id,
            do: ~p"/accounts/#{@account}",
            else: ~p"/clubs/#{@club}/accounts"
        }
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :accounts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    account = Accounting.get_account!(id, [:club, :entry])

    activate_opening_balance = nil
    if account.opening_balance == Money.new(:EUR, 0) && not Enum.any?(account.entry) && account.class in ["Anlagevermögen", "Umlaufvermögen", "Eigen-/Fremdkapital","Fremdkapital"] do
      activate_opening_balance = true
    else
      activate_opening_balance = false
    end

    socket
    |> assign(:page_title, "Konto bearbeiten")
    |> assign(:account, account)
    |> assign(:club, account.club)
    |> assign(:activate_opening_balance, activate_opening_balance)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Konto erstellen")
    |> assign(:account, %Account{
      club_id: club.id,
      club: club
    })
    |> assign(:club, club)
    |> assign(:activate_opening_balance, false)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    account = Accounting.get_account!(id)
    {:ok, _} = Accounting.delete_account(account)

    {:noreply,
     socket
     |> put_flash(:info, "Konto erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{account.club_id}/accounts")}
  end
end
