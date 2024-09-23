defmodule SportywebWeb.LocationLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Asset
  alias Sportyweb.Organization.Club

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
          id="location-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input_grids>
            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:name]} type="text" label="Name" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:reference_number]}
                  type="text"
                  label="Referenznummer (optional)"
                />
              </div>

              <div class="col-span-12">
                <.input field={@form[:description]} type="textarea" label="Beschreibung (optional)" />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <.inputs_for :let={postal_address} field={@form[:postal_addresses]}>
                <.live_component
                  module={SportywebWeb.PolymorphicLive.PostalAddressesFormComponent}
                  id={"postal_addresses_#{postal_address.index}"}
                  postal_address={postal_address}
                />
              </.inputs_for>
            </.input_grid>

            <.input_grid class="pt-6">
              <.inputs_for :let={email} field={@form[:emails]}>
                <.live_component
                  module={SportywebWeb.PolymorphicLive.EmailFormComponent}
                  id={"email_#{email.index}"}
                  email={email}
                />
              </.inputs_for>

              <.inputs_for :let={phone} field={@form[:phones]}>
                <.live_component
                  module={SportywebWeb.PolymorphicLive.PhoneFormComponent}
                  id={"phone_#{phone.index}"}
                  phone={phone}
                />
              </.inputs_for>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12">
                <.label>Notizen (optional)</.label>
                <.inputs_for :let={note} field={@form[:notes]}>
                  <.input field={note[:content]} type="textarea" />
                </.inputs_for>
              </div>
            </.input_grid>

            <.input_grid :if={@location.id && !show_delete_button?(@location)} class="pt-6">
              <div class="col-span-12">
                <div
                  class="bg-amber-100 border border-amber-400 text-amber-800 px-4 py-3 rounded relative"
                  role="alert"
                >
                  Dieser Standort kann derzeit nicht gelöscht, da er als Hauptstandort des Vereins festgelegt wurde.
                  Wird dies im
                  <.link navigate={~p"/clubs/#{@location.club}/edit"} class="text-amber-900 underline">
                    Verein
                  </.link>
                  geändert, kann im Anschluss eine Löschung dieses Standorts erfolgen.
                </div>
              </div>
            </.input_grid>
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
            </div>
            <.button
              :if={show_delete_button?(@location)}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @location.id})}
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
  def update(%{location: location} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Asset.change_location(location))
     end)}
  end

  @impl true
  def handle_event("validate", %{"location" => location_params}, socket) do
    changeset = Asset.change_location(socket.assigns.location, location_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"location" => location_params}, socket) do
    save_location(socket, socket.assigns.action, location_params)
  end

  defp save_location(socket, :edit, location_params) do
    case Asset.update_location(socket.assigns.location, location_params) do
      {:ok, _location} ->
        {:noreply,
         socket
         |> put_flash(:info, "Standort erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_location(socket, :new, location_params) do
    location_params =
      Enum.into(location_params, %{
        "club_id" => socket.assigns.location.club.id
      })

    case Asset.create_location(location_params) do
      {:ok, _location} ->
        {:noreply,
         socket
         |> put_flash(:info, "Standort erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp show_delete_button?(location) do
    location.id && !Club.is_main_location?(location.club, location)
  end
end
