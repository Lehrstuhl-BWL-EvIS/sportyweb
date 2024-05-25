defmodule SportywebWeb.LocationLive.FeeNew do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset
  alias Sportyweb.Finance.Fee
  alias Sportyweb.Polymorphic.InternalEvent
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
        fee_object={@location}
        navigate={if @fee.id, do: ~p"/fees/#{@fee}", else: ~p"/locations/#{@location}"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :assets)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"id" => id}) do
    # If the route behind this function should be more than a redirect in the future, put it in its own "Index"-LiveView!
    socket
    |> push_navigate(to: ~p"/locations/#{id}")
  end

  # There is no "edit" action in this LiveView because that gets handled in the default SportywebWeb.FeeLive.NewEdit

  defp apply_action(socket, :new, %{"id" => id}) do
    location = Asset.get_location!(id, [:club])
    type = "location"

    socket
    |> assign(
      :page_title,
      "Spezifische Gebühr erstellen (#{get_key_for_value(Fee.get_valid_types(), type)})"
    )
    |> assign(:fee, %Fee{
      club_id: location.club.id,
      club: location.club,
      is_general: false,
      type: type,
      locations: [location],
      internal_events: [%InternalEvent{}],
      notes: [%Note{}]
    })
    |> assign(:location, location)
    |> assign(:club, location.club)
  end
end
