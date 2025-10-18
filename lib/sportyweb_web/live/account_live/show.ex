defmodule SportywebWeb.AccountLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounting

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :accounts)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    account = Accounting.get_account!(id, [:club])

    {:noreply,
     socket
     |> assign(:page_title, "Konto: #{account.name}")
     |> assign(:account, account)
     |> assign(:club, account.club)}
  end
end
