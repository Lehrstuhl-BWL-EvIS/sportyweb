defmodule SportywebWeb.ClubLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Organization

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
          id="club-form"
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

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:website_url]} type="text" label="URL (optional)" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:foundation_date]} type="date" label="Gründungsdatum" />
              </div>
            </.input_grid>

            <.input_grid :if={@club.id && Enum.any?(@club.locations)} class="pt-6">
              <div class="col-span-12">
                <.input
                  field={@form[:location_id]}
                  type="select"
                  label="Hauptstandort (optional)"
                  options={@club.locations |> Enum.map(&{&1.name, &1.id})}
                  prompt="Bitte auswählen"
                />
              </div>
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
              <.inputs_for :let={financial_data} field={@form[:financial_data]}>
                <.live_component
                  module={SportywebWeb.PolymorphicLive.FinancialDataFormComponent}
                  id={"financial_data_#{financial_data.index}"}
                  financial_data={financial_data}
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
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
            </div>
            <.button
              :if={@club.id}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @club.id})}
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
  def update(%{club: club} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Organization.change_club(club))
     end)}
  end

  @impl true
  def handle_event("validate", %{"club" => club_params}, socket) do
    changeset = Organization.change_club(socket.assigns.club, club_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
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
        {:noreply, assign(socket, form: to_form(changeset))}
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
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
