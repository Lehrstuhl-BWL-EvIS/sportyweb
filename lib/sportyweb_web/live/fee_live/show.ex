defmodule SportywebWeb.FeeLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Fee

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    fee = Legal.get_fee!(id, [:ancestors, :club, :contracts, :notes, :successor])
    fee_title = if fee.is_general, do: "Allgemeine", else: "Spezifische"
    club_navigation_current_item = case fee.type do
      "department" -> :structure
      "group" -> :structure
      "event" -> :calendar
      "venue" -> :assets
      "equipment" -> :assets
      _ -> :finances
    end

    {:noreply,
     socket
     |> assign(:club_navigation_current_item, club_navigation_current_item)
     |> assign(:page_title, "#{fee_title} Gebühr: #{fee.name}")
     |> assign(:fee, fee)
     |> assign(:club, fee.club)}
  end
end
