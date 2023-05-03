defmodule SportywebWeb.EquipmentLive.FeeNew do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset
  alias Sportyweb.Legal.Fee
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
        navigate={if @fee.id, do: ~p"/fees/#{@fee}", else: ~p"/equipment/#{@equipment}"}
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
    equipment = Asset.get_equipment!(id, [venue: :club])
    type = "equipment"

    socket
    |> assign(:page_title, "Spezifische Gebühr erstellen (#{get_key_for_value(Fee.get_valid_types, type)})")
    |> assign(:fee, %Fee{
      club_id: equipment.venue.club.id,
      club: equipment.venue.club,
      is_general: false,
      type: type,
      equipment: [equipment],
      notes: [%Note{}]}
    )
    |> assign(:equipment, equipment)
    |> assign(:club, equipment.venue.club)
  end
end
