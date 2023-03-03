defmodule SportywebWeb.GroupLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:club_navigation_current_item, :structure)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    group = Organization.get_group!(id, [department: :club])

    {:noreply,
     socket
     |> assign(:page_title, "Gruppe: #{group.name}")
     |> assign(:group, group)
     |> assign(:department, group.department)
     |> assign(:club, group.department.club)}
  end
end
