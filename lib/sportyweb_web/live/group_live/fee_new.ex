defmodule SportywebWeb.GroupLive.FeeNew do
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
        navigate={if @fee.id, do: ~p"/fees/#{@fee}", else: ~p"/groups/#{@group}"}
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

  # There is no "edit" action in this LiveView because that gets handled in the default SportywebWeb.FeeLive.NewEdit

  defp apply_action(socket, :new, %{"id" => id}) do
    group = Organization.get_group!(id, [department: :club])
    type = "group"

    socket
    |> assign(:page_title, "Spezifische Gebühr erstellen (#{get_key_for_value(Fee.get_valid_types, type)})")
    |> assign(:fee, %Fee{
      club_id: group.department.club.id,
      club: group.department.club,
      is_general: false,
      type: type,
      groups: [group],
      notes: [%Note{}]}
    )
    |> assign(:group, group)
    |> assign(:club, group.department.club)
  end
end
