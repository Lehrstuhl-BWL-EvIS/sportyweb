defmodule SportywebWeb.UserApplicationRoleLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.RBAC.UserRole

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage user_application_role records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="user_application_role-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >

        <:actions>
          <.button phx-disable-with="Saving...">Save User application role</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user_application_role: user_application_role} = assigns, socket) do
    changeset = UserRole.change_user_application_role(user_application_role)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user_application_role" => user_application_role_params}, socket) do
    changeset =
      socket.assigns.user_application_role
      |> UserRole.change_user_application_role(user_application_role_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user_application_role" => user_application_role_params}, socket) do
    save_user_application_role(socket, socket.assigns.action, user_application_role_params)
  end

  defp save_user_application_role(socket, :edit, user_application_role_params) do
    case UserRole.update_user_application_role(socket.assigns.user_application_role, user_application_role_params) do
      {:ok, _user_application_role} ->
        {:noreply,
         socket
         |> put_flash(:info, "User application role updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_user_application_role(socket, :new, user_application_role_params) do
    case UserRole.create_user_application_role(user_application_role_params) do
      {:ok, _user_application_role} ->
        {:noreply,
         socket
         |> put_flash(:info, "User application role created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
