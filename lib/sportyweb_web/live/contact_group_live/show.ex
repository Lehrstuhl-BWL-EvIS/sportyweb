defmodule SportywebWeb.ContactGroupLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal.Membership
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contact_groups)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    contact_group =
      Personal.get_contact_group!(id, [
        :club,
        contacts: [
          memberships: [
            :club,
            :department,
            :group
          ]
        ]
      ])

    {:noreply,
     socket
     |> assign(:contact_group, contact_group)
     |> stream(:contacts, contact_group.contacts)}
  end
end
