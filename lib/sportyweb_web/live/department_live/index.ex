defmodule SportywebWeb.DepartmentLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Organization.Department

  @impl true
  def mount(%{"club_id" => club_id}, _session, socket) do
    {:ok, assign(socket, :departments, list_departments(club_id))}
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :departments, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    department = Organization.get_department!(id, [:club])

    socket
    |> assign(:page_title, "Edit Department")
    |> assign(:department, department)
    |> assign(:club, department.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "New Department")
    |> assign(:department, %Department{club: club})
    |> assign(:club, club)
  end

  defp apply_action(socket, :index_root, _params) do
    socket
    |> redirect(to: "/clubs")
  end

  defp apply_action(socket, :index, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Listing Departments")
    |> assign(:department, nil)
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    department = Organization.get_department!(id)
    {:ok, _} = Organization.delete_department(department)

    {:noreply, assign(socket, :departments, list_departments(department.club_id))}
  end

  defp list_departments(club_id) do
    Organization.list_departments(club_id)
  end
end
