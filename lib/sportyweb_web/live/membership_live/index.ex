defmodule SportywebWeb.MembershipLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Membership
  alias Sportyweb.Legal.Contract


  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :memberships)}
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
    memberships = Personal.list_memberships(club_id, nil, [:contact, :club, :department, :group, contracts: [:fee]])

    socket
    |> assign(:page_title, "Mitgliedschaften")
    |> assign(:club, club)
    |> assign(:sorting, %{})
    |> stream(:memberships, memberships)
  end


  @impl true
  def handle_event("sort-by-column", %{"Status" => _direction} = wanted_sorting, socket) do
    sort_contacts(wanted_sorting, "Status", :state, socket)
  end

  def sort_contacts(%{} = wanted_sorting, column_label, column_database_field, socket) do
    wanted_direction = wanted_sorting[column_label];

    database_sorting = cond do
      wanted_direction == "asc" -> [asc: column_database_field]
      wanted_direction == "desc" -> [desc: column_database_field]
      true -> nil
    end

    club_id = socket.assigns.club.id
    memberships = Personal.list_memberships(club_id, database_sorting, [:contact, :club, :department, :group, contracts: [:fee]])

    socket = socket
             |> assign(:sorting, %{column_label => wanted_direction})
             |> stream(:memberships, memberships)
    {:noreply, socket}
  end

end
