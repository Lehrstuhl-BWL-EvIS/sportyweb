defmodule SportywebWeb.ClubLive.FormComponent do
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
          id="club-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
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

            <div class="col-span-12 md:col-span-6">
              <.input field={@form[:website_url]} type="text" label="URL (optional)" />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.input field={@form[:foundation_date]} type="date" label="Gründungsdatum" />
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
              :if={@club.id}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @club.id})}
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
  def update(%{club: club} = assigns, socket) do
    changeset = Organization.change_club(club)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"club" => club_params}, socket) do
    changeset =
      socket.assigns.club
      |> Organization.change_club(club_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"club" => club_params}, socket) do
    save_club(socket, socket.assigns.action, club_params)
  end

  defp save_club(socket, :edit, club_params) do
    case Organization.update_club(socket.assigns.club, club_params) do
      {:ok, _club} ->
        {:noreply,
         socket
         |> put_flash(:info, "Verein erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_club(socket, :new, club_params) do
    case Organization.create_club(club_params) do
      {:ok, _club} ->
        {:noreply,
         socket
         |> put_flash(:info, "Verein erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
