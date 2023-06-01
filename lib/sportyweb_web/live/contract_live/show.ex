defmodule SportywebWeb.ContractLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal.Fee

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :fees)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    contract = Legal.get_contract!(id, [:club, :clubs, :contact, :contract_pauses, :departments, :fee, :groups])
    contract_object = Contract.get_object(contract)

    {:noreply,
     socket
     |> assign(:page_title, "Vertrag (#{get_key_for_value(Fee.get_valid_types, contract.fee.type)})")
     |> assign(:contract, contract)
     |> assign(:contract_object, contract_object)
     |> assign(:club, contract.club)}
  end
end
