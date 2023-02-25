defmodule SportywebWeb.FeeLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Fee

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :fees, Legal.list_fees())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Fee")
    |> assign(:fee, Legal.get_fee!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Fee")
    |> assign(:fee, %Fee{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Fees")
    |> assign(:fee, nil)
  end

  @impl true
  def handle_info({SportywebWeb.FeeLive.FormComponent, {:saved, fee}}, socket) do
    {:noreply, stream_insert(socket, :fees, fee)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    fee = Legal.get_fee!(id)
    {:ok, _} = Legal.delete_fee(fee)

    {:noreply, stream_delete(socket, :fees, fee)}
  end
end
