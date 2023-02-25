defmodule SportywebWeb.DepartmentRoleLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.RBAC.Role

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage department_role records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="department_role-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Department role</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{department_role: department_role} = assigns, socket) do
    changeset = Role.change_department_role(department_role)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"department_role" => department_role_params}, socket) do
    changeset =
      socket.assigns.department_role
      |> Role.change_department_role(department_role_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"department_role" => department_role_params}, socket) do
    save_department_role(socket, socket.assigns.action, department_role_params)
  end

  defp save_department_role(socket, :edit, department_role_params) do
    case Role.update_department_role(socket.assigns.department_role, department_role_params) do
      {:ok, _department_role} ->
        {:noreply,
         socket
         |> put_flash(:info, "Department role updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_department_role(socket, :new, department_role_params) do
    case Role.create_department_role(department_role_params) do
      {:ok, _department_role} ->
        {:noreply,
         socket
         |> put_flash(:info, "Department role created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
