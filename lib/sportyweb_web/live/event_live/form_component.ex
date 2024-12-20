defmodule SportywebWeb.EventLive.FormComponent do
  use SportywebWeb, :live_component
  import Ecto.Changeset

  alias Sportyweb.Asset
  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.card>
        <.simple_form
          for={@form}
          id="event-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input_grids>
            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:name]} type="text" label="Name" />
              </div>

              <div class="col-span-12 md:col-span-3">
                <.input field={@form[:reference_number]} type="text" label="Referenznummer" />
              </div>

              <div class="col-span-12 md:col-span-3">
                <.input
                  field={@form[:status]}
                  type="select"
                  label="Status"
                  options={Event.get_valid_statuses()}
                />
              </div>

              <div class="col-span-12">
                <.input field={@form[:description]} type="textarea" label="Beschreibung" />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:minimum_participants]}
                  type="number"
                  label="Minimale Anzahl an Teilnehmern (optional)"
                />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:maximum_participants]}
                  type="number"
                  label="Maximale Anzahl an Teilnehmern (optional)"
                />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:minimum_age_in_years]}
                  type="number"
                  label="Mindestalter (optional)"
                />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:maximum_age_in_years]}
                  type="number"
                  label="Höchstalter (optional)"
                />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12">
                <.input
                  field={@form[:venue_type]}
                  type="select"
                  label="Art des Veranstaltungsorts"
                  options={Event.get_valid_venue_types()}
                />
              </div>

              <%= if @venue_type == "location" do %>
                <div class="col-span-12">
                  <.inputs_for :let={location} field={@form[:locations]}>
                    <.input
                      field={location[:id]}
                      type="select"
                      label="Standort"
                      options={Asset.list_locations(@event.club_id) |> Enum.map(&{&1.name, &1.id})}
                    />
                  </.inputs_for>
                </div>
              <% end %>

              <%= if @venue_type == "postal_address" do %>
                <SportywebWeb.PolymorphicLive.PostalAddressesFormComponent.render form={@form} />
              <% end %>

              <%= if @venue_type == "free_form" do %>
                <div class="col-span-12">
                  <.input field={@form[:venue_description]} type="textarea" label="Veranstaltungsort" />
                </div>
              <% end %>
            </.input_grid>

            <.input_grid class="pt-6">
              <SportywebWeb.PolymorphicLive.EmailsFormComponent.render form={@form} />
            </.input_grid>

            <.input_grid class="pt-6">
              <SportywebWeb.PolymorphicLive.PhonesFormComponent.render form={@form} />
            </.input_grid>

            <.input_grid class="pt-6">
              <SportywebWeb.PolymorphicLive.NotesFormComponent.render form={@form} />
            </.input_grid>
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
            </div>
            <.button
              :if={@event.id}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @event.id})}
              data-confirm="Unwiderruflich löschen?"
            >
              Löschen
            </.button>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def update(%{event: event} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:venue_type, event.venue_type)
     |> assign_new(:form, fn ->
       to_form(Calendar.change_event(event))
     end)}
  end

  @impl true
  def handle_event("validate", %{"event" => event_params}, socket) do
    changeset = Calendar.change_event(socket.assigns.event, event_params)

    {:noreply,
     socket
     |> assign(:venue_type, get_field(changeset, :venue_type))
     |> assign(form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"event" => event_params}, socket) do
    save_event(socket, socket.assigns.action, event_params)
  end

  defp save_event(socket, :edit, event_params) do
    case Calendar.update_event(socket.assigns.event, event_params) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Veranstaltung erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_event(socket, :new, event_params) do
    event_params =
      Enum.into(event_params, %{
        "club_id" => socket.assigns.event.club.id
      })

    case Calendar.create_event(event_params) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Veranstaltung erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
