defmodule SportywebWeb.MembershipLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Membership

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    membership =
      Legal.get_membership!(id, [:club, :department, :group, :contact, contract: [:fee]])

    {:noreply,
     socket
     |> assign(
       :page_title,
       Membership.print(membership)
     )
     |> assign(:membership, membership)
     |> assign(:club, membership.club)}
  end
end
