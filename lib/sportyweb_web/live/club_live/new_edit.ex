defmodule SportywebWeb.ClubLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Organization.Club
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.FinancialData
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.ClubLive.FormComponent}
        id={@club.id || :new}
        title={@page_title}
        action={@live_action}
        club={@club}
        navigate={if @club.id, do: ~p"/clubs/#{@club}", else: ~p"/clubs"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :dashboard)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    club = Organization.get_club!(id, [:emails, :financial_data, :phones, :notes, :locations])

    socket
    |> assign(:page_title, "Verein bearbeiten")
    |> assign(:club, club)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Verein erstellen")
    |> assign(:club, %Club{
      emails: [%Email{}],
      phones: [%Phone{}],
      financial_data: [%FinancialData{}],
      notes: [%Note{}]
    })
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    club = Organization.get_club!(id)
    {:ok, _} = Organization.delete_club(club)

    {:noreply,
     socket
     |> put_flash(:info, "Verein erfolgreich gelöscht")
     |> push_navigate(to: "/clubs")}
  end
end
