defmodule SportywebWeb.SubsidyLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Finance
  alias Sportyweb.Finance.Subsidy
  alias Sportyweb.Organization
  alias Sportyweb.Polymorphic.InternalEvent
  alias Sportyweb.Polymorphic.Note

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.SubsidyLive.FormComponent}
        id={@subsidy.id || :new}
        title={@page_title}
        action={@live_action}
        subsidy={@subsidy}
        navigate={if @subsidy.id, do: ~p"/subsidies/#{@subsidy}", else: ~p"/clubs/#{@club}/subsidies"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :subsidies)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    subsidy = Finance.get_subsidy!(id, [:club, :internal_events, :notes])

    socket
    |> assign(:page_title, "Zuschuss bearbeiten")
    |> assign(:subsidy, subsidy)
    |> assign(:club, subsidy.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Zuschuss erstellen")
    |> assign(:subsidy, %Subsidy{
      club_id: club.id,
      club: club,
      internal_events: [%InternalEvent{}],
      notes: [%Note{}]}
    )
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subsidy = Finance.get_subsidy!(id)
    {:ok, _} = Finance.delete_subsidy(subsidy)

    {:noreply,
     socket
     |> put_flash(:info, "Zuschuss erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{subsidy.club_id}/subsidies")}
  end
end
