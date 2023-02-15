defmodule SportywebWeb.EquipmentLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset
  alias Sportyweb.Asset.Equipment

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :equipment_collection, list_equipment())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Equipment")
    |> assign(:equipment, Asset.get_equipment!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Equipment")
    |> assign(:equipment, %Equipment{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Equipment")
    |> assign(:equipment, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    equipment = Asset.get_equipment!(id)
    {:ok, _} = Asset.delete_equipment(equipment)

    {:noreply, assign(socket, :equipment_collection, list_equipment())}
  end

  defp list_equipment do
    Asset.list_equipment()
  end
end
