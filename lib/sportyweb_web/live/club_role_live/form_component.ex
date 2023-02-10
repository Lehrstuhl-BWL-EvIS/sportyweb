defmodule SportywebWeb.ClubRoleLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.RBAC.Role

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage club_role records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="club_role-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Club role</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{club_role: club_role} = assigns, socket) do
    changeset = Role.change_club_role(club_role)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"club_role" => club_role_params}, socket) do
    changeset =
      socket.assigns.club_role
      |> Role.change_club_role(club_role_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"club_role" => club_role_params}, socket) do
    save_club_role(socket, socket.assigns.action, club_role_params)
  end

  defp save_club_role(socket, :edit, club_role_params) do
    case Role.update_club_role(socket.assigns.club_role, club_role_params) do
      {:ok, _club_role} ->
        {:noreply,
         socket
         |> put_flash(:info, "Club role updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_club_role(socket, :new, club_role_params) do
    case Role.create_club_role(club_role_params) do
      {:ok, _club_role} ->
        {:noreply,
         socket
         |> put_flash(:info, "Club role created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
