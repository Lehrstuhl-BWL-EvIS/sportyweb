defmodule SportywebWeb.ClubLive.ContractNew do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal.Contract
  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.ContractLive.FormComponent}
        id={@contract.id || :new}
        title={@page_title}
        action={@live_action}
        contract={@contract}
        contract_object={@club}
        navigate={if @contract.id, do: ~p"/contracts/#{@contract}", else: ~p"/clubs/#{@club}/contacts"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"id" => id}) do
    # If the route behind this function should be more than a redirect in the future, put it in its own "Index"-LiveView!
    socket
    |> push_navigate(to: ~p"/clubs/#{id}")
  end

  # There is no "edit" action in this LiveView because that gets handled in the default SportywebWeb.ContractLive.NewEdit

  defp apply_action(socket, :new, %{"id" => id}) do
    club = Organization.get_club!(id, [:contracts])

    socket
    |> assign(:page_title, "Mitgliedschaftsvertrag erstellen (Verein)")
    |> assign(:contract, %Contract{
      club_id: club.id,
      club: club,
      signing_date: Date.utc_today(),
      clubs: [club]}
    )
    |> assign(:club, club)
  end
end
