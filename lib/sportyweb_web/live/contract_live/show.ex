defmodule SportywebWeb.ContractLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Finance.Fee
  alias Sportyweb.History
  alias SportywebWeb.ChangeLive.LastChangeComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :fees)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    contract = Legal.get_contract!(id, [:club, :contact, :department, :fee, :group, :membership])
    contract_object = Contract.print_object(contract)
    contract_partner = Contract.print_partner(Contract.get_partner(contract))

    last_change = History.get_last_change("contract", contract.id)

    {:noreply,
     socket
     |> assign(
       :page_title,
       "Vertrag (#{get_key_for_value(Fee.get_valid_types(), contract.fee.type)})"
     )
     |> assign(:contract, contract)
     |> assign(:last_change, last_change)
     |> assign(:contract_object, contract_object)
     |> assign(:contract_partner, contract_partner)
     |> assign(:club, contract.club)}
  end
end
