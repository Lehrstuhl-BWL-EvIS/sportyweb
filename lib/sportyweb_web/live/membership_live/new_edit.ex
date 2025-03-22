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

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    membership = %Membership{
      club_id: club.id,
      club: club,
      state: "active",
      start_date: Date.utc_today(),
      department: nil,
      group: nil,
      contact: nil,
      contracts: []
    }

    socket
    |> assign(club: club)
    |> assign(membership: membership)
    |> assign(page_title: "Neue Mitgliedschaft anlegen")
  end
end
