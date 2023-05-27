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
        <%= @title %>
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
                  options={Event.get_valid_statuses}
                />
              </div>

              <div class="col-span-12">
                <.input field={@form[:description]} type="textarea" label="Beschreibung" />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:minimum_participants]} type="number" label="Minimale Anzahl an Teilnehmern" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:maximum_participants]} type="number" label="Maximale Anzahl an Teilnehmern" />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:minimum_age_in_years]} type="number" label="Mindestalter" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:maximum_age_in_years]} type="number" label="Höchstalter" />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12">
                <.input
                  field={@form[:location_type]}
                  type="select"
                  label="Art des Veranstaltungsorts"
                  options={Event.get_valid_location_types}
                />
              </div>

              <%= if @location_type == "venue" do %>
                <.inputs_for :let={f_nested} field={@form[:venues]}>
                  <div class="col-span-12">
                    <.input
                      field={f_nested[:id]}
                      type="select"
                      label="Standort"
                      options={Asset.list_venues(@event.club_id) |> Enum.map(&{&1.name, &1.id})}
                    />
                  </div>
                </.inputs_for>
              <% end %>

              <%= if @location_type == "postal_address" do %>
                <.live_component
                  module={SportywebWeb.PolymorphicLive.PostalAddressesFormComponent}
                  id={"postal_addresses"}
                  form={@form}
                />
              <% end %>

              <%= if @location_type == "free_form" do %>
                <div class="col-span-12">
                  <.input field={@form[:location_description]} type="textarea" label="Veranstaltungsort" />
                </div>
              <% end %>
            </.input_grid>

            <.input_grid class="pt-6">
              <.live_component
                module={SportywebWeb.PolymorphicLive.EmailsFormComponent}
                id={"emails"}
                form={@form}
              />

              <.live_component
                module={SportywebWeb.PolymorphicLive.PhonesFormComponent}
                id={"phones"}
                form={@form}
              />
            </.input_grid>

            <.input_grid class="pt-6">
              <.live_component
                module={SportywebWeb.PolymorphicLive.NotesFormComponent}
                id={"notes"}
                form={@form}
              />
            </.input_grid>
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.link navigate={@navigate} class="mx-2 py-1 px-1 text-sm font-semibold hover:underline">
                Abbrechen
              </.link>
            </div>
            <.button
              :if={@event.id}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @event.id})}
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
  def update(%{event: event} = assigns, socket) do
    changeset = Calendar.change_event(event)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:location_type, event.location_type)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"event" => event_params}, socket) do
    changeset =
      socket.assigns.event
      |> Calendar.change_event(event_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:location_type, get_field(changeset, :location_type))
     |> assign_form(changeset)}
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
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_event(socket, :new, event_params) do
    event_params = Enum.into(event_params, %{
      "club_id" => socket.assigns.event.club.id
    })

    case Calendar.create_event(event_params) do
      {:ok, _event} ->
        {:noreply,
         socket
         |> put_flash(:info, "Veranstaltung erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
