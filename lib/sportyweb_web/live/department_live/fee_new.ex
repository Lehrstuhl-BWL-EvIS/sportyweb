defmodule SportywebWeb.DepartmentLive.FeeNew do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal.Fee
  alias Sportyweb.Organization
  alias Sportyweb.Polymorphic.Note

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.FeeLive.FormComponent}
        id={@fee.id || :new}
        title={@page_title}
        action={@live_action}
        fee={@fee}
        fee_object={@department}
        navigate={if @fee.id, do: ~p"/fees/#{@fee}", else: ~p"/departments/#{@department}"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:club_navigation_current_item, :structure)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"id" => id}) do
    # If the route behind this function should be more than a redirect in the future, put it in its own "Index"-LiveView!
    socket
    |> push_navigate(to: ~p"/departments/#{id}")
  end

  # There is no "edit" action in this LiveView because that gets handled in the default SportywebWeb.FeeLive.NewEdit

  defp apply_action(socket, :new, %{"id" => id}) do
    department = Organization.get_department!(id, [:club])
    type = "department"

    socket
    |> assign(:page_title, "Spezifische Gebühr erstellen (#{get_key_for_value(Fee.get_valid_types, type)})")
    |> assign(:fee, %Fee{
      club_id: department.club.id,
      club: department.club,
      is_general: false,
      type: type,
      departments: [department],
      notes: [%Note{}]}
    )
    |> assign(:department, department)
    |> assign(:club, department.club)
  end
end
