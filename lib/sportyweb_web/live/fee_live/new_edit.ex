defmodule SportywebWeb.FeeLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Fee
  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.FeeLive.FormComponent}
        id={@fee.id || :new}
        title={@page_title}
        action={@live_action}
        fee={@fee}
        navigate={if @fee.id, do: ~p"/fees/#{@fee}", else: ~p"/clubs/#{@fee.club}/fees"}
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
    fee = Legal.get_fee!(id, [:club])

    socket
    |> assign(:page_title, "Allgemeine Gebühr bearbeiten (#{get_key_for_value(Fee.get_valid_types, fee.type)})")
    |> assign(:fee, fee)
    |> assign(:club, fee.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id, "type" => type}) do
    club = Organization.get_club!(club_id)

    socket
    |> assign(:page_title, "Allgemeine Gebühr erstellen (#{get_key_for_value(Fee.get_valid_types, type)})")
    |> assign(:fee, %Fee{
      club_id: club.id,
      club: club,
      is_general: true,
      type: type}
    )
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    fee = Legal.get_fee!(id)
    {:ok, _} = Legal.delete_fee(fee)

    {:noreply,
     socket
     |> put_flash(:info, "Allgemeine Gebühr erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{fee.club_id}/fees")}
  end
end
