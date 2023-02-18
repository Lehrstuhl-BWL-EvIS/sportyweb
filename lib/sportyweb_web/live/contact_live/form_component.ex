defmodule SportywebWeb.ContactLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Personal

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
          id="contact-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="grid grid-cols-12 gap-x-4 gap-y-6">
            <div class="col-span-12">
              <.input field={{f, :type}} type="text" label="Art" />
            </div>

            <div class="col-span-12">
              <.input field={{f, :organization_name}} type="text" label="Organisationsname" />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={{f, :person_last_name}} type="text" label="Nachname" />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={{f, :person_first_name_1}} type="text" label="Vorname" />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={{f, :person_first_name_2}} type="text" label="2. Vorname (optional)" />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.input field={{f, :person_gender}} type="text" label="Geschlecht" />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.input field={{f, :person_birthday}} type="date" label="Geburtstag" />
            </div>
          </div>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.link navigate={@navigate} class="mx-2 py-1 px-1 text-sm font-semibold hover:underline">
                Abbrechen
              </.link>
            </div>
            <.button
              :if={@contact.id}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @contact.id})}
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
  def update(%{contact: contact} = assigns, socket) do
    changeset = Personal.change_contact(contact)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"contact" => contact_params}, socket) do
    changeset =
      socket.assigns.contact
      |> Personal.change_contact(contact_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"contact" => contact_params}, socket) do
    contact_params = Enum.into(contact_params, %{
      "club_id" => socket.assigns.contact.club.id
    })

    save_contact(socket, socket.assigns.action, contact_params)
  end

  defp save_contact(socket, :edit, contact_params) do
    case Personal.update_contact(socket.assigns.contact, contact_params) do
      {:ok, _contact} ->
        {:noreply,
         socket
         |> put_flash(:info, "Kontakt erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_contact(socket, :new, contact_params) do
    case Personal.create_contact(contact_params) do
      {:ok, _contact} ->
        {:noreply,
         socket
         |> put_flash(:info, "Kontakt erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
