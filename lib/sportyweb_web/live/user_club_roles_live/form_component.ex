defmodule SportywebWeb.UserClubRolesLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.AccessControl

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage user_club_roles records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="user_club_roles-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save User club roles</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user_club_roles: user_club_roles} = assigns, socket) do
    changeset = AccessControl.change_user_club_roles(user_club_roles)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user_club_roles" => user_club_roles_params}, socket) do
    changeset =
      socket.assigns.user_club_roles
      |> AccessControl.change_user_club_roles(user_club_roles_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user_club_roles" => user_club_roles_params}, socket) do
    save_user_club_roles(socket, socket.assigns.action, user_club_roles_params)
  end

  defp save_user_club_roles(socket, :edit, user_club_roles_params) do
    case AccessControl.update_user_club_roles(socket.assigns.user_club_roles, user_club_roles_params) do
      {:ok, _user_club_roles} ->
        {:noreply,
         socket
         |> put_flash(:info, "User club roles updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_user_club_roles(socket, :new, user_club_roles_params) do
    case AccessControl.create_user_club_roles(user_club_roles_params) do
      {:ok, _user_club_roles} ->
        {:noreply,
         socket
         |> put_flash(:info, "User club roles created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
