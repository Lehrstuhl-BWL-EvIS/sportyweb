defmodule SportywebWeb.SubsidyLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Subsidy
  alias Sportyweb.Organization
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
        navigate={if @subsidy.id, do: ~p"/subsidies/#{@subsidy}", else: ~p"/clubs/#{@subsidy.club}/subsidies"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:club_navigation_current_item, :finances)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    subsidy = Legal.get_subsidy!(id, [:club, :notes])

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
      notes: [%Note{}]}
    )
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subsidy = Legal.get_subsidy!(id)
    {:ok, _} = Legal.delete_subsidy(subsidy)

    {:noreply,
     socket
     |> put_flash(:info, "Zuschuss erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{subsidy.club_id}/subsidies")}
  end
end
