defmodule SportywebWeb.ContactLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact

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
          id="contact-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input_grid>
            <div class="col-span-12">
              <.input
                field={@form[:type]}
                type="select"
                label="Art"
                options={Contact.get_valid_types}
                prompt="Bitte auswählen"
              />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.input field={@form[:organization_name]} type="text" label="Organisationsname" />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.input
                field={@form[:organization_type]}
                type="select"
                label="Organisationstyp"
                options={Contact.get_valid_organization_types}
                prompt="Bitte auswählen"
              />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:person_last_name]} type="text" label="Nachname" />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:person_first_name_1]} type="text" label="Vorname" />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:person_first_name_2]} type="text" label="2. Vorname (optional)" />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.input
                field={@form[:person_gender]}
                type="select"
                label="Geschlecht"
                options={Contact.get_valid_genders}
                prompt="Bitte auswählen"
              />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.input field={@form[:person_birthday]} type="date" label="Geburtstag" />
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
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"contact" => contact_params}, socket) do
    changeset =
      socket.assigns.contact
      |> Personal.change_contact(contact_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
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
        {:noreply, assign_form(socket, changeset)}
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
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
