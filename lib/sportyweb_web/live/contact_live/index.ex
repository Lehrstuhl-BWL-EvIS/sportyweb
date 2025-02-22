defmodule SportywebWeb.ContactLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Personal

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index_root, _params) do
    socket
    |> redirect(to: "/clubs")
  end

  defp apply_action(socket, :index, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)
    contacts = Personal.list_contacts(club_id, nil, [:postal_addresses, :emails, :phones, :memberships])

    socket
    |> assign(:page_title, "Kontakte")
    |> assign(:club, club)
    |> assign(:sorting, %{})
    |> stream(:contacts, contacts)
  end

  @impl true
  def handle_event("sort-by-column", %{"Art" => direction}, socket) do
    club_id = socket.assigns.club.id
    sorting = cond do
      direction == "asc" -> [asc: :type]
      direction == "desc" -> [desc: :type]
      true -> nil
    end
    contacts = Personal.list_contacts(club_id, sorting, [:postal_addresses, :emails, :phones, :memberships])

    socket = socket
     |> assign(:sorting, %{"Art" => direction})
     |> stream(:contacts, contacts)
    {:noreply, socket}
  end

  @impl true
  def handle_event("sort-by-column", %{"Name" => direction}, socket) do
    club_id = socket.assigns.club.id
    sorting = cond do
      direction == "asc" -> [asc: :name]
      direction == "desc" -> [desc: :name]
      true -> nil
    end
    contacts = Personal.list_contacts(club_id, sorting, [:postal_addresses, :emails, :phones, :memberships])

    socket = socket
             |> assign(:sorting, %{"Name" => direction})
             |> stream(:contacts, contacts)
    {:noreply, socket}
  end


end
