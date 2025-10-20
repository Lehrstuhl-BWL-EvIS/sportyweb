defmodule SportywebWeb.AccountLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Accounting
  alias Sportyweb.Organization

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :accounts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index_root, _params) do
    socket
    |> redirect(to: "/clubs")
  end

  defp apply_action(socket, :index, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)
    accounts = Accounting.list_accounts(club_id)

    socket
    |> assign(:page_title, "Kontenplan")
    |> assign(:club, club)
    |> stream(:accounts, accounts)
  end

  @impl true
  def handle_event("import", _params, socket) do
    club_id = socket.assigns.club.id

    case Accounting.import_accounts(club_id) do
      :ok ->
        {:noreply,
         socket
         |> put_flash(:info, "Kontenrahmen erfolgreich importiert")
         |> push_patch(to: ~p"/clubs/#{club_id}/accounts")}

      :error ->
        {:noreply,
         socket
         |> put_flash(:error, "Kontenrahmen konnte nicht importiert werden")
         |> push_patch(to: ~p"/clubs/#{club_id}/accounts")}
    end
  end
end
