defmodule SportywebWeb.GroupLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Documents.Document
  alias Sportyweb.Documents.GroupDocument

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :structure)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    group =
      Organization.get_group!(id, [
        :contacts,
        :emails,
        :notes,
        :phones,
        department: :club,
        fees: :internal_events,
        group_documents: Document.with_active_documents(GroupDocument)
      ])

    {:noreply,
     socket
     |> assign(:page_title, "Gruppe: #{group.name}")
     |> assign(:group, group)
     |> assign(:department, group.department)
     |> assign(:documents, group.group_documents)
     |> assign(:club, group.department.club)}
  end
end
