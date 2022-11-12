defmodule SportywebWeb.HouseholdLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Membership
  alias Sportyweb.Membership.Household

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :households, list_households())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Household")
    |> assign(:household, Membership.get_household!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Household")
    |> assign(:household, %Household{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Households")
    |> assign(:household, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    household = Membership.get_household!(id)
    {:ok, _} = Membership.delete_household(household)

    {:noreply, assign(socket, :households, list_households())}
  end

  defp list_households do
    Membership.list_households()
  end
end
