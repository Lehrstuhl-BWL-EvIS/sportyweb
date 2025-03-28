defmodule SportywebWeb.ContractLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Contract

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contracts)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    contract =
      Legal.get_contract!(id, [
        :club,
        :contact,
        :partner_department,
        :partner_group,
        :fee,
        membership: [:club, :department, :group]
      ])

    {:noreply,
     socket
     |> assign(
       :page_title,
       "Vertrag zwischen #{contract.contact.name} und #{Contract.get_internal_partner(contract).name}"
     )
     |> assign(:contract, contract)
     |> assign(:club, contract.club)}
  end
end
