defmodule SportywebWeb.ContactLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Finance.Fee
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Legal.Membership
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact

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
        memberships: [
          :club,
          :department,
          :group
        ],
        contracts: [
          :club,
          :department,
          :group,
          :membership,
          fee: :internal_events
        ]
      ])

    requested_memberships =
      Enum.filter(contact.memberships, fn m -> m.state == "PENDING" || m.state == "REJECTED" end)

    {:noreply,
     socket
     |> assign(:page_title, "Kontakt: #{contact.name}")
     |> assign(:contact, contact)
     |> assign(:club, contact.club)
     |> stream(:requested_memberships, requested_memberships)
     |> stream(:contracts, contact.contracts)}
  end
end
