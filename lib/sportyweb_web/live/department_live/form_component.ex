defmodule SportywebWeb.DepartmentLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Organization
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone

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
          <.input_grid>
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

            <div class="col-span-12">
              <.input_grid>
                <.inputs_for :let={f_nested} field={f[:emails]}>
                  <div class="col-span-12 md:col-span-8">
                    <.input field={{f_nested, :address}} type="text" label="E-Mail" />
                  </div>

                  <div class="col-span-12 md:col-span-4">
                    <.input field={{f_nested, :type}} type="select" label="Art"
                    options={Email.get_valid_types} prompt="Bitte auswählen" />
                  </div>
                </.inputs_for>
              </.input_grid>
            </div>

            <div class="col-span-12">
              <.input_grid>
                <.inputs_for :let={f_nested} field={f[:phones]}>
                  <div class="col-span-12 md:col-span-8">
                    <.input field={{f_nested, :number}} type="text" label="Telefon" />
                  </div>

                  <div class="col-span-12 md:col-span-4">
                    <.input field={{f_nested, :type}} type="select" label="Art"
                    options={Phone.get_valid_types} prompt="Bitte auswählen" />
                  </div>
                </.inputs_for>
              </.input_grid>
            </div>

            <div class="col-span-12">
              <.label>Notizen (optional)</.label>
              <.inputs_for :let={f_nested} field={f[:notes]}>
                <.input_grid>
                  <div class="col-span-11">
                    <.input field={{f_nested, :content}} type="textarea" />
                  </div>

                  <div class="col-span-1">
                    <.input field={{f_nested, :delete}} type="checkbox" />
                    <.button type="button" class="bg-rose-700 hover:bg-rose-800">
                      <Heroicons.trash class="text-white h-4 w-4" />
                    </.button>
                  </div>
                </.input_grid>
              </.inputs_for>
            </div>

            <div class="col-span-12">
              <.button type="button" phx-click="add_note" phx-target={@myself}>Notiz hinzufügen</.button>
            </div>
          </.input_grid>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.link navigate={@navigate} class="mx-2 py-1 px-1 text-sm font-semibold hover:underline">
                Abbrechen
              </.link>
            </div>
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

  def handle_event("add_note", _params, socket) do
    # Get the current, already changed list of notes or the original list as fallback
    current_notes = Map.get(socket.assigns.changeset.changes, :notes, socket.assigns.department.notes)
    # Append a new, empty note
    new_notes = current_notes ++ [%Note{}]
    # Create a new changeset with the new, longer list
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:notes, new_notes)

    {:noreply, assign(socket, :changeset, changeset)}
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
