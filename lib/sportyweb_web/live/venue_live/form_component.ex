defmodule SportywebWeb.VenueLive.FormComponent do
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
          id="venue-form"
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
                <.input field={@form[:reference_number]} type="text" label="Referenznummer (optional)" />
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

            <.input_grid class="pt-6" :if={!show_delete_button?(@venue)}>
              <div class="col-span-12">
                <div class="bg-amber-100 border border-amber-400 text-amber-800 px-4 py-3 rounded relative" role="alert">
                  Dieser Standort kann derzeit nicht gelöscht, da er als Hauptstandort des Vereins festgelegt wurde.
                  Wird dies im
                  <.link navigate={~p"/clubs/#{@venue.club}/edit"} class="text-amber-900 underline">Verein</.link>
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
              :if={show_delete_button?(@venue)}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @venue.id})}
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
  def update(%{venue: venue} = assigns, socket) do
    changeset = Asset.change_venue(venue)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"venue" => venue_params}, socket) do
    changeset =
      socket.assigns.venue
      |> Asset.change_venue(venue_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"venue" => venue_params}, socket) do
    save_venue(socket, socket.assigns.action, venue_params)
  end

  defp save_venue(socket, :edit, venue_params) do
    case Asset.update_venue(socket.assigns.venue, venue_params) do
      {:ok, _venue} ->
        {:noreply,
         socket
         |> put_flash(:info, "Standort erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_venue(socket, :new, venue_params) do
    venue_params = Enum.into(venue_params, %{
      "club_id" => socket.assigns.venue.club.id
    })

    case Asset.create_venue(venue_params) do
      {:ok, _venue} ->
        {:noreply,
         socket
         |> put_flash(:info, "Standort erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp show_delete_button?(venue) do
    venue.id && !Club.is_main_venue?(venue.club, venue)
  end
end
