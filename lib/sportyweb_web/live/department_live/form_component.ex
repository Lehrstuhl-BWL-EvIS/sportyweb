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
          <div class="grid grid-cols-12 gap-x-4 gap-y-6">
            <div class="col-span-12 md:col-span-6">
              <.input field={{f, :name}} type="text" label="Name" />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.input field={{f, :reference_number}} type="text" label="Referenznummer (optional)" />
            </div>

            <div class="col-span-12">
              <.input field={{f, :description}} type="textarea" label="Beschreibung (optional)" />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.input field={{f, :created_at}} type="date" label="Erstellungsdatum" />
            </div>
          </div>

          <:actions>
            <.button phx-disable-with="Speichern...">Speichern</.button>
            <.button
              :if={@department.id}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @department.id})}
              data-confirm="Unwiderruflich löschen?">
              Löschen
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
         |> put_flash(:info, "Abteilung erfolgreich aktualisiert")
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
         |> put_flash(:info, "Abteilung erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
