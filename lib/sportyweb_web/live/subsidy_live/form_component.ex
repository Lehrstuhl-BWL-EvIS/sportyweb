defmodule SportywebWeb.SubsidyLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Finance

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
          id="subsidy-form"
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
              <div class="col-span-12">
                <.input field={@form[:amount]} type="text" label="Betrag in Euro" />
                <.input_description>Das €-Zeichen kann, muss aber nicht angegeben werden.</.input_description>
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <.inputs_for :let={internal_event} field={@form[:internal_events]}>
                <.live_component
                  module={SportywebWeb.PolymorphicLive.InternalEventFormComponent}
                  id={"internal_event_#{internal_event.index}"}
                  internal_event={internal_event}
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
              :if={show_delete_button?(@subsidy)}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @subsidy.id})}
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
  def update(%{subsidy: subsidy} = assigns, socket) do
    changeset = Finance.change_subsidy(subsidy)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"subsidy" => subsidy_params}, socket) do
    changeset =
      socket.assigns.subsidy
      |> Finance.change_subsidy(subsidy_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"subsidy" => subsidy_params}, socket) do
    save_subsidy(socket, socket.assigns.action, subsidy_params)
  end

  defp save_subsidy(socket, :edit, subsidy_params) do
    case Finance.update_subsidy(socket.assigns.subsidy, subsidy_params) do
      {:ok, _subsidy} ->
        {:noreply,
         socket
         |> put_flash(:info, "Zuschuss erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_subsidy(socket, :new, subsidy_params) do
    subsidy_params = Enum.into(subsidy_params, %{
      "club_id" => socket.assigns.subsidy.club.id
    })

    case Finance.create_subsidy(subsidy_params) do
      {:ok, _subsidy} ->
        {:noreply,
         socket
         |> put_flash(:info, "Zuschuss erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp show_delete_button?(subsidy) do
    subsidy.id && !Enum.any?(subsidy.fees)
  end
end
