defmodule SportywebWeb.DepartmentLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Documents.Document
  alias Sportyweb.Documents.DepartmentDocument

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :structure)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    department =
      Organization.get_department!(id, [
        :club,
        :contacts,
        :emails,
        :groups,
        :notes,
        :phones,
        fees: :internal_events,
        department_documents: Document.with_active_documents(DepartmentDocument),
      ])

    {:noreply,
     socket
     |> assign(:page_title, "Abteilung: #{department.name}")
     |> assign(:department, department)
     |> assign(:club, department.club)
     |> assign(:documents, department.department_documents)
     |> stream(:groups, department.groups)}
  end
end
