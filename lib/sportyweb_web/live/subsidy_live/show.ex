defmodule SportywebWeb.SubsidyLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Finance
  alias Sportyweb.Finance.Subsidy

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :subsidies)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    subsidy = Finance.get_subsidy!(id, [:club, :fees, :notes])

    {:noreply,
     socket
     |> assign(:page_title, "Zuschuss: #{subsidy.name}")
     |> assign(:subsidy, subsidy)
     |> assign(:club, subsidy.club)}
  end
end
