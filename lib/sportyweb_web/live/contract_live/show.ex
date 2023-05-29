defmodule SportywebWeb.ContractLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal.Fee

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:club_navigation_current_item, :finances)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    contract = Legal.get_contract!(id, [:club, :clubs, :contact, :contract_pauses, :departments, :fee, :groups])
    {object, object_path} = Contract.get_object(contract)

    {:noreply,
     socket
     |> assign(:page_title, "Vertrag (#{get_key_for_value(Fee.get_valid_types, contract.fee.type)})")
     |> assign(:object, object)
     |> assign(:object_path, object_path)
     |> assign(:contract, contract)
     |> assign(:club, contract.club)}
  end
end
