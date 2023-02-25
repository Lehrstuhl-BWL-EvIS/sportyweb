defmodule SportywebWeb.UserDepartmentRoleLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.RBAC.UserRole

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage user_department_role records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="user_department_role-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >

        <:actions>
          <.button phx-disable-with="Saving...">Save User department role</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user_department_role: user_department_role} = assigns, socket) do
    changeset = UserRole.change_user_department_role(user_department_role)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user_department_role" => user_department_role_params}, socket) do
    changeset =
      socket.assigns.user_department_role
      |> UserRole.change_user_department_role(user_department_role_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user_department_role" => user_department_role_params}, socket) do
    save_user_department_role(socket, socket.assigns.action, user_department_role_params)
  end

  defp save_user_department_role(socket, :edit, user_department_role_params) do
    case UserRole.update_user_department_role(socket.assigns.user_department_role, user_department_role_params) do
      {:ok, _user_department_role} ->
        {:noreply,
         socket
         |> put_flash(:info, "User department role updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_user_department_role(socket, :new, user_department_role_params) do
    case UserRole.create_user_department_role(user_department_role_params) do
      {:ok, _user_department_role} ->
        {:noreply,
         socket
         |> put_flash(:info, "User department role created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
