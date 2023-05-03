defmodule SportywebWeb.GroupLive.FormComponent do
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
          for={@form}
          id="group-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input_grid>
            <%= if @group.id do %>
              <div class="col-span-12">
                <.input
                  field={@form[:department_id]}
                  type="select"
                  label="Abteilung"
                  options={Organization.list_departments(@group.department.club_id) |> Enum.map(&{&1.name, &1.id})}
                />
              </div>
            <% end %>

            <div class="col-span-12 md:col-span-6">
              <.input field={@form[:name]} type="text" label="Name" />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.input field={@form[:reference_number]} type="text" label="Referenznummer (optional)" />
            </div>

            <div class="col-span-12">
              <.input field={@form[:description]} type="textarea" label="Beschreibung (optional)" />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.input field={@form[:created_at]} type="date" label="Erstellungsdatum" />
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
                :if={@group.id}
                class="bg-rose-700 hover:bg-rose-800"
                phx-click={JS.push("delete", value: %{id: @group.id})}
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
  def update(%{group: group} = assigns, socket) do
    changeset = Organization.change_group(group)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"group" => group_params}, socket) do
    changeset =
      socket.assigns.group
      |> Organization.change_group(group_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"group" => group_params}, socket) do
    save_group(socket, socket.assigns.action, group_params)
  end

  defp save_group(socket, :edit, group_params) do
    case Organization.update_group(socket.assigns.group, group_params) do
      {:ok, _group} ->
        {:noreply,
         socket
         |> put_flash(:info, "Gruppe erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_group(socket, :new, group_params) do
    group_params = Enum.into(group_params, %{
      "department_id" => socket.assigns.group.department.id
    })

    case Organization.create_group(group_params) do
      {:ok, _group} ->
        {:noreply,
         socket
         |> put_flash(:info, "Gruppe erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
