defmodule SportywebWeb.DepartmentLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Organization.Department

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.DepartmentLive.FormComponent}
        id={:new}
        title={@page_title}
        action={:new}
        department={@department}
        navigate={~p"/clubs/#{@club}/departments"}
      />
    </div>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    department = Organization.get_department!(id, [:club])

    socket
    |> assign(:page_title, "Abteilung bearbeiten")
    |> assign(:department, department)
    |> assign(:club, department.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Abteilung erstellen")
    |> assign(:department, %Department{club: club})
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    department = Organization.get_department!(id)
    {:ok, _} = Organization.delete_department(department)

    {:noreply,
     socket
     |> redirect(to: "/clubs/#{department.club_id}/departments")}
  end
end
