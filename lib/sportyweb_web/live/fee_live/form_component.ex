defmodule SportywebWeb.FeeLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Legal

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
          id="fee-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="divide-y divide-zinc-200 space-y-8">
            <.input_grid>
              <div class="hidden">
                <.input field={@form[:type]} type="hidden" readonly />
              </div>

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
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:base_fee_in_eur_cent]} type="number" label="Grundgebühr in EUR" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:admission_fee_in_eur_cent]} type="number" label="Aufnahmegebühr in EUR (optional)" />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:is_recurring]} type="checkbox" label="Wiederholend?" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:is_group_only]} type="checkbox" label="Nur für Gruppen?" />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:minimum_age_in_years]} type="number" label="Minimales Alter" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:maximum_age_in_years]} type="number" label="Maximales Alter" />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:commission_at]} type="date" label="Verwendung ab" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:decommission_at]} type="date" label="Verwendung bis (optional)" />
              </div>
            </.input_grid>
          </div>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.link navigate={@navigate} class="mx-2 py-1 px-1 text-sm font-semibold hover:underline">
                Abbrechen
              </.link>
            </div>
            <.button
              :if={@fee.id}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @fee.id})}
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
  def update(%{fee: fee} = assigns, socket) do
    changeset = Legal.change_fee(fee)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"fee" => fee_params}, socket) do
    changeset =
      socket.assigns.fee
      |> Legal.change_fee(fee_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"fee" => fee_params}, socket) do
    fee_params = Enum.into(fee_params, %{
      "club_id" => socket.assigns.fee.club.id
    })

    save_fee(socket, socket.assigns.action, fee_params)
  end

  defp save_fee(socket, :edit, fee_params) do
    case Legal.update_fee(socket.assigns.fee, fee_params) do
      {:ok, _fee} ->
        {:noreply,
         socket
         |> put_flash(:info, "Gebühr erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_fee(socket, :new, fee_params) do
    case Legal.create_fee(fee_params) do
      {:ok, _fee} ->
        {:noreply,
         socket
         |> put_flash(:info, "Gebühr erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
