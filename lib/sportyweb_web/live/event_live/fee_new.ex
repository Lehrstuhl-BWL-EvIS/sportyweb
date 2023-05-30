defmodule SportywebWeb.EventLive.FeeNew do
  use SportywebWeb, :live_view

  alias Sportyweb.Calendar
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
        fee_object={@event}
        navigate={if @fee.id, do: ~p"/fees/#{@fee}", else: ~p"/events/#{@event}"}
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
    |> push_navigate(to: ~p"/events/#{id}")
  end

  # There is no "edit" action in this LiveView because that gets handled in the default SportywebWeb.FeeLive.NewEdit

  defp apply_action(socket, :new, %{"id" => id}) do
    event = Calendar.get_event!(id, [:club])
    type = "event"

    socket
    |> assign(:page_title, "Spezifische Gebühr erstellen (#{get_key_for_value(Fee.get_valid_types, type)})")
    |> assign(:fee, %Fee{
      club_id: event.club.id,
      club: event.club,
      is_general: false,
      type: type,
      events: [event],
      notes: [%Note{}]}
    )
    |> assign(:event, event)
    |> assign(:club, event.club)
  end
end
