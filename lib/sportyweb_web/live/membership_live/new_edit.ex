defmodule SportywebWeb.MembershipLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Membership

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@page_title}
      </.header>
      <.card>
        <.live_component
          id={@membership.id || :new}
          module={SportywebWeb.Membership.FormComponent}
          action={@live_action}
          membership={@membership}
          club={@club}
        />
      </.card>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :memberships)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    IO.inspect(params)

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    membership = Personal.get_membership!(id, [:contact, :club, :contracts, department: [:fees], group:  [:fees]])

    socket
    |> assign(club: membership.club)
    |> assign(membership: membership)
    |> assign(
      page_title:
        "Mitgliedschaft von #{membership.contact.name} in #{Membership.get_smallest_community(membership).name} bearbeiten"
    )
  end

  defp apply_action(socket, :new, %{"club_id" => club_id} = params) do
    club = Organization.get_club!(club_id)

    contact = case params["contact"] do
      nil -> nil
      contact_id -> Personal.get_contact!(contact_id)
    end

    department = case params["department"] do
      nil -> nil
      department_id -> Organization.get_department!(department_id)
    end

    group = case params["group"] do
      nil -> nil
      group_id -> Organization.get_group!(group_id)
    end


    membership = %Membership{
      club_id: club.id,
      club: club,
      state: "active",
      start_date: Date.utc_today(),
      department: department,
      department_id: if department == nil  do nil else department.id end,
      group: group,
      group_id: if group == nil  do nil else group.id end,
      contact: contact,
      contact_id: if contact == nil do nil else contact.id end,
      contracts: []
    }

    socket
    |> assign(club: club)
    |> assign(membership: membership)
    |> assign(page_title: "Neue Mitgliedschaft anlegen")
  end
end
