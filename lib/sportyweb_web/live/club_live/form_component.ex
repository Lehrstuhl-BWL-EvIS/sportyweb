defmodule SportywebWeb.ClubLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Organization

  @impl true
  def update(%{club: club} = assigns, socket) do
    changeset = Organization.change_club(club)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"club" => club_params}, socket) do
    changeset =
      socket.assigns.club
      |> Organization.change_club(club_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"club" => club_params}, socket) do
    save_club(socket, socket.assigns.action, club_params)
  end

  defp save_club(socket, :edit, club_params) do
    case Organization.update_club(socket.assigns.club, club_params) do
      {:ok, _club} ->
        {:noreply,
         socket
         |> put_flash(:info, "Club updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_club(socket, :new, club_params) do
    case Organization.create_club(club_params) do
      {:ok, _club} ->
        {:noreply,
         socket
         |> put_flash(:info, "Club created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
