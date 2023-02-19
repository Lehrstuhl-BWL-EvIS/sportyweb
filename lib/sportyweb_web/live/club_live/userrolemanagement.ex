defmodule SportywebWeb.ClubLive.Userrolemanagement do
  use SportywebWeb, :live_view

  alias Sportyweb.AccessControl.PolicyClub

  @impl true
  def mount(%{"id" => club_id}, _session, socket) do
      {:ok,
        socket
        |> assign(:club_id, club_id)
        |> assign(:club_name, PolicyClub.get_club_name_by_id(club_id))
        |> assign(:clubmembers, PolicyClub.get_club_members_and_their_roles(club_id))
        |> assign(:roles, PolicyClub.get_club_roles_for_administration(socket.assigns.current_user, club_id))
        |> assign(:ucrchanges, %{})
      }
  end

  @impl true
  def handle_params(%{"id" => club_id}, _, socket) do
    if PolicyClub.can?(socket.assigns.current_user, socket.assigns.live_action, club_id) do
      {:noreply, socket}
    else
      {:noreply,
        socket
        |> put_flash(:error, "No permission to manage user roles of club members.")
        |> redirect(to: ~p"/clubs/#{club_id}")
      }
    end
  end

  def handle_event("role_selected", %{"ucr_id" => ucr_id, "role" => role }, socket) do
    update_ucrchanges = socket.assigns.ucrchanges |> Map.put(ucr_id, role) |> clean_ucrchanges(ucr_id, role)
    {:noreply, socket |> assign(ucrchanges: update_ucrchanges)}
  end

  @impl true
  def handle_event("save", _, socket) do
    if PolicyClub.can?(socket.assigns.current_user, socket.assigns.live_action, socket.assigns.club_id) do
      save_ucrchanges(socket, socket.assigns.ucrchanges)
    else
      {:noreply,
        socket
        |> put_flash(:error, "No permission to manage user roles of club members.")
        |> redirect(to: ~p"/clubs/#{socket.assigns.club_id}")
      }
    end
  end

  defp clean_ucrchanges(ucrchanges, ucr_id, ""), do: Map.delete(ucrchanges, ucr_id)
  defp clean_ucrchanges(ucrchanges, ucr_id, role_name) do
    if PolicyClub.ucr_has_role?(ucr_id, role_name), do: Map.delete(ucrchanges, ucr_id), else: ucrchanges
  end

  defp save_ucrchanges(socket, ucrchanges) do
    [flash_t, flash_msg] = if PolicyClub.ucr_change_role(ucrchanges) do
      [:error, "Saving failed for some or all entries"]
    else
      [:info, "Role settings saved succesfully"]
    end

    {:noreply,
      socket
      |> assign(:ucrchanges, %{})
      |> assign(:clubmembers, PolicyClub.get_club_members_and_their_roles(socket.assigns.club_id))
      |> put_flash(flash_t, flash_msg)}
  end
end
