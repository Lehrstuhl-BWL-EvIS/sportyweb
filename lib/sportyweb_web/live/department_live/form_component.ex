defmodule SportywebWeb.DepartmentLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.card>
        <.simple_form
          :let={f}
          for={@changeset}
          id="department-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input field={{f, :name}} type="text" label="name" />
          <.input field={{f, :type}} type="text" label="type" />
          <.input field={{f, :created_at}} type="date" label="created_at" />
          <:actions>
            <.button phx-disable-with="Saving...">Save Department</.button>
            <.button
              :if={@department.id}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @department.id})}
              data-confirm="Unwiderruflich löschen?">
              Delete
            </.button>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def update(%{department: department} = assigns, socket) do
    changeset = Organization.change_department(department)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"department" => department_params}, socket) do
    changeset =
      socket.assigns.department
      |> Organization.change_department(department_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"department" => department_params}, socket) do
    department_params = Enum.into(department_params, %{
      "club_id" => socket.assigns.department.club.id
    })

    save_department(socket, socket.assigns.action, department_params)
  end

  defp save_department(socket, :edit, department_params) do
    case Organization.update_department(socket.assigns.department, department_params) do
      {:ok, _department} ->
        {:noreply,
         socket
         |> put_flash(:info, "Department updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_department(socket, :new, department_params) do
    case Organization.create_department(department_params) do
      {:ok, _department} ->
        {:noreply,
         socket
         |> put_flash(:info, "Department created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
