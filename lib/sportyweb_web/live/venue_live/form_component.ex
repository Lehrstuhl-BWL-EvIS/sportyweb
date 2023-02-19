defmodule SportywebWeb.VenueLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Asset

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
          id="venue-form"
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
          </div>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.link navigate={@navigate} class="mx-2 py-1 px-1 text-sm font-semibold hover:underline">
                Abbrechen
              </.link>
            </div>
            <.button
              :if={@venue.id && !@venue.is_main}
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
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"venue" => venue_params}, socket) do
    changeset =
      socket.assigns.venue
      |> Asset.change_venue(venue_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"venue" => venue_params}, socket) do
    venue_params = Enum.into(venue_params, %{
      "club_id" => socket.assigns.venue.club.id
    })

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
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_venue(socket, :new, venue_params) do
    case Asset.create_venue(venue_params) do
      {:ok, _venue} ->
        {:noreply,
         socket
         |> put_flash(:info, "Standort erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
