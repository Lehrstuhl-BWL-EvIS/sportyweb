defmodule SportywebWeb.ContactLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Finance.Fee
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.Membership

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    contact =
      Personal.get_contact!(id, [
        :club,
        :emails,
        :financial_data,
        :notes,
        :phones,
        :postal_addresses,
        memberships: [:club, :department, :group, :contracts]
      ])

      socket = socket
               |> assign(:page_title, "Kontakt: #{contact.name}")
               |> assign(:contact, contact)
               |> assign(:club, contact.club)
               |> assign(:show_membership_contracts, false)
               |> stream(:memberships, contact.memberships)
               |> load_contacts()
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle-show-membership-contracts", _, socket) do
    show_membership_contracts = !socket.assigns.show_membership_contracts
    socket = socket
             |> assign(:show_membership_contracts, show_membership_contracts)
             |> load_contacts()
    {:noreply, socket}
  end

  def load_contacts(socket) do
    show_membership_contracts = socket.assigns.show_membership_contracts
    contact_id = socket.assigns.contact.id
    contracts = Legal.list_contracts_of_contact(contact_id, [:clubs, :departments, :groups, fee: :internal_events], !show_membership_contracts)

    socket
    |> stream(:contracts, contracts, reset: true)
  end
end
