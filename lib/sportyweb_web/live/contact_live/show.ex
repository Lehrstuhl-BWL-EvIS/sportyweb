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
        ],
        contact_groups: [:contacts]
      ])

    requested_memberships =
      Enum.filter(contact.memberships, fn m -> m.state == "PENDING" || m.state == "REJECTED" end)

    {:noreply,
     socket
     |> assign(:page_title, "Kontakt: #{contact.name}")
     |> assign(:contact, contact)
     |> assign(:club, contact.club)
     |> stream(:requested_memberships, requested_memberships)
     |> stream(:contact_groups, contact.contact_groups)
     |> stream(:contracts, contact.contracts)}
  end

  def print_other_contacts_in_group(contact_group, contact) do
    contact_group.contacts
    |> Enum.filter(fn c -> c.id != contact.id end)
    |> Enum.map_join(", ", fn c -> c.name end)
  end
end
