defmodule SportywebWeb.VenueLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset
  alias Sportyweb.Asset.Venue

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :venues, list_venues())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Venue")
    |> assign(:venue, Asset.get_venue!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Venue")
    |> assign(:venue, %Venue{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Venues")
    |> assign(:venue, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    venue = Asset.get_venue!(id)
    {:ok, _} = Asset.delete_venue(venue)

    {:noreply, assign(socket, :venues, list_venues())}
  end

  defp list_venues do
    Asset.list_venues()
  end
end
