defmodule SportywebWeb.UserClubRoleLive.New do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounts
  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
    socket
    |> assign(:club_navigation_current_item, :authorization)}
  end

  @impl true
  def handle_params(%{"club_id" => club_id}, _url, socket) do
    {:noreply,
      socket
      |> assign(:users, Accounts.list_all_users)
      |> assign(:club, Organization.get_club!(club_id))
    }
  end
end
