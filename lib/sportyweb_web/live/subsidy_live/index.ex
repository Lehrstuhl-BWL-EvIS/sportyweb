defmodule SportywebWeb.SubsidyLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Subsidy

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :subsidies, Legal.list_subsidies())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Subsidy")
    |> assign(:subsidy, Legal.get_subsidy!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Subsidy")
    |> assign(:subsidy, %Subsidy{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Subsidies")
    |> assign(:subsidy, nil)
  end

  @impl true
  def handle_info({SportywebWeb.SubsidyLive.FormComponent, {:saved, subsidy}}, socket) do
    {:noreply, stream_insert(socket, :subsidies, subsidy)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subsidy = Legal.get_subsidy!(id)
    {:ok, _} = Legal.delete_subsidy(subsidy)

    {:noreply, stream_delete(socket, :subsidies, subsidy)}
  end
end
