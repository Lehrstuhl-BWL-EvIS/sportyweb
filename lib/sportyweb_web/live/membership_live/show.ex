defmodule SportywebWeb.MembershipLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Membership

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :memberships)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    membership  = Personal.get_membership!(id, [:club, :contact, :department, :group, :contracts]);

    contact_name = membership.contact.name
    community_name = Membership.get_smallest_community(membership).name
    {:noreply,
     socket
     |> assign(
       :page_title,
       "Mitgliedschaft von (#{contact_name} in #{community_name})"
     )
     |> assign(:membership, membership)
     |> assign(:community_name, community_name)
     |> assign(:club, membership.club)}
  end
end
