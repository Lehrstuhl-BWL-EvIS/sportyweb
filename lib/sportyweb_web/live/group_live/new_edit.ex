defmodule SportywebWeb.GroupLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Organization.Group
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.GroupLive.FormComponent}
        id={@group.id || :new}
        title={@page_title}
        action={@live_action}
        group={@group}
        navigate={if @group.id, do: ~p"/groups/#{@group}", else: ~p"/departments/#{@department}"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :structure)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    group = Organization.get_group!(id, [:emails, :phones, :notes, department: :club])

    socket
    |> assign(:page_title, "Gruppe bearbeiten")
    |> assign(:group, group)
    |> assign(:department, group.department)
    |> assign(:club, group.department.club)
  end

  defp apply_action(socket, :new, %{"department_id" => department_id}) do
    department = Organization.get_department!(department_id, [:club, :emails, :phones, :notes])

    socket
    |> assign(:page_title, "Gruppe erstellen")
    |> assign(:group, %Group{
      department_id: department.id,
      department: department,
      emails: [%Email{}],
      phones: [%Phone{}],
      notes: [%Note{}]
    })
    |> assign(:department, department)
    |> assign(:club, department.club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    group = Organization.get_group!(id)
    {:ok, _} = Organization.delete_group(group)

    {:noreply,
     socket
     |> put_flash(:info, "Gruppe erfolgreich gelöscht")
     |> push_navigate(to: "/departments/#{group.department_id}")}
  end
end
