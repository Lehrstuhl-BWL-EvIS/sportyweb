defmodule SportywebWeb.MembersLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Personal

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :members)}
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
    club = Organization.get_club!(club_id);
    contacts = Personal.list_contacts_of_members(club_id, nil, [:postal_addresses, :emails, :phones, memberships: [:group, :department, :club ]])

    socket
    |> assign(:page_title, "Mitgliedschaften")
    |> assign(:club, club)
    |> assign(:sorting, %{})
    |> stream(:contacts, contacts)
  end


  @impl true
  def handle_event("sort-by-column", %{"Art" => _direction} = wanted_sorting, socket) do
    sort_contacts(wanted_sorting, "Art", :type, socket)
  end

  @impl true
  def handle_event("sort-by-column", %{"Vorname" => _direction} = wanted_sorting, socket) do
    sort_contacts(wanted_sorting, "Vorname", :person_first_name_1, socket)
  end

  @impl true
  def handle_event("sort-by-column", %{"Nachname" => _direction} = wanted_sorting, socket) do
    sort_contacts(wanted_sorting, "Nachname", :person_last_name, socket)
  end

  @impl true
  def handle_event("sort-by-column", %{"Name" => _direction} = wanted_sorting, socket) do
    sort_contacts(wanted_sorting, "Name", :name, socket)
  end

  @impl true
  def handle_event("sort-by-column", %{"Geburtsdatum" => _direction} = wanted_sorting, socket) do
    sort_contacts(wanted_sorting, "Geburtsdatum", :person_birthday, socket)
  end

  def sort_contacts(%{} = wanted_sorting, column_label, column_database_field, socket) do
    wanted_direction = wanted_sorting[column_label];

    database_sorting = cond do
      wanted_direction == "asc" -> [asc: column_database_field]
      wanted_direction == "desc" -> [desc: column_database_field]
      true -> nil
    end

    club_id = socket.assigns.club.id
    contacts = Personal.list_contacts_of_members(club_id, database_sorting, [:postal_addresses, :emails, :phones, memberships: [:group, :department, :club ]])

    socket = socket
             |> assign(:sorting, %{column_label => wanted_direction})
             |> stream(:contacts, contacts)
    {:noreply, socket}
  end

end
