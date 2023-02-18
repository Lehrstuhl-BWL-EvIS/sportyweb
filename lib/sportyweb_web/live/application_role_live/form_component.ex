defmodule SportywebWeb.ApplicationRoleLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.RBAC.Role

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage application_role records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="application_role-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Application role</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{application_role: application_role} = assigns, socket) do
    changeset = Role.change_application_role(application_role)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"application_role" => application_role_params}, socket) do
    changeset =
      socket.assigns.application_role
      |> Role.change_application_role(application_role_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"application_role" => application_role_params}, socket) do
    save_application_role(socket, socket.assigns.action, application_role_params)
  end

  defp save_application_role(socket, :edit, application_role_params) do
    case Role.update_application_role(socket.assigns.application_role, application_role_params) do
      {:ok, _application_role} ->
        {:noreply,
         socket
         |> put_flash(:info, "Application role updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_application_role(socket, :new, application_role_params) do
    case Role.create_application_role(application_role_params) do
      {:ok, _application_role} ->
        {:noreply,
         socket
         |> put_flash(:info, "Application role created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
