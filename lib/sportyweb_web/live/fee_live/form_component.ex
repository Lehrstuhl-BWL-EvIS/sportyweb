defmodule SportywebWeb.FeeLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Asset
  alias Sportyweb.Calendar
  alias Sportyweb.Legal
  alias Sportyweb.Legal.Fee
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
          id="fee-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="hidden">
            <.input field={@form[:type]} type="hidden" readonly />
            <.input field={@form[:is_general]} type="checkbox" />
          </div>

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
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:base_fee_in_eur]} type="text" label="Grundgebühr in EUR" />

                <div class="hidden">
                  <.input field={@form[:base_fee_in_eur_cent]} type="hidden" readonly />
                </div>
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:admission_fee_in_eur]} type="text" label="Aufnahmegebühr in EUR (optional)" />

                <div class="hidden">
                  <.input field={@form[:admission_fee_in_eur_cent]} type="hidden" readonly />
                </div>
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
                <.input field={@form[:minimum_age_in_years]} type="number" label="Mindestalter (optional)" min="0" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:maximum_age_in_years]}
                  type="number"
                  label="Höchstalter (optional)"
                  min="0"
                  phx-change="update_successor_fees"
                />
              </div>

              <div class="col-span-12" :if={Enum.any?(@successor_fees)}>
                <.input
                  field={@form[:successor_id]}
                  type="select"
                  label="Nachfolger-Gebühr (optional)"
                  options={@successor_fees |> Enum.map(&{&1.name, &1.id})}
                  prompt="Bitte auswählen"
                />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:commission_date]} type="date" label="Verwendung ab" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:archive_date]} type="date" label="Archiviert ab (optional)" />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12">
                <.label>Notizen (optional)</.label>
                <.inputs_for :let={note} field={@form[:notes]}>
                  <.input field={note[:content]} type="textarea" />
                </.inputs_for>
              </div>
            </.input_grid>

            <.input_grid class="pt-6" :if={@fee.id && !Fee.is_archived?(@fee) && (Enum.any?(@fee.ancestors) || Enum.any?(@fee.contracts))}>
              <div class="col-span-12">
                <div class="bg-amber-100 border border-amber-400 text-amber-800 px-4 py-3 rounded relative" role="alert">
                  Diese Gebühr kann nicht gelöscht, sondern nur archiviert werden, denn:
                  <ul class="list-disc pl-4">
                    <li :if={Enum.any?(@fee.contracts)}>Sie wird in <%= Enum.count(@fee.contracts) %> Verträgen verwendet.</li>
                    <li :if={Enum.any?(@fee.ancestors)}>Sie dient <%= Enum.count(@fee.ancestors) %> anderen Gebühren als Nachfolger.</li>
                  </ul>
                </div>
              </div>
            </.input_grid>

            <.input_grid class="pt-6" :if={@fee.id && Fee.is_archived?(@fee)}>
              <div class="col-span-12">
                <div class="bg-amber-100 border border-amber-400 text-amber-800 px-4 py-3 rounded relative" role="alert">
                  Diese Gebühr ist derzeit archiviert.
                  Wird das Datum im Feld "Archiviert ab" gelöscht oder durch ein Zukünftiges ersetzt,
                  lässt sich die Archivierung komplett bzw. temporär aufheben.
                </div>
              </div>
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
              :if={@fee.id && !(Enum.any?(@fee.ancestors) || Enum.any?(@fee.contracts))}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @fee.id})}
              data-confirm="Unwiderruflich löschen?">
              Löschen
            </.button>
            <.button
              :if={@fee.id && !Fee.is_archived?(@fee) && (Enum.any?(@fee.ancestors) || Enum.any?(@fee.contracts))}
              class="bg-amber-700 hover:bg-amber-800"
              phx-target={@myself}
              phx-click={JS.push("archive", value: %{id: @fee.id})}
              data-confirm="Archivieren?">
              Archivieren
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
     |> assign_form(changeset)
     |> assign_successor_fees(fee, fee.maximum_age_in_years)}
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
    save_fee(socket, socket.assigns.action, fee_params)
  end

  @impl true
  def handle_event("update_successor_fees", %{"fee" => %{"maximum_age_in_years" => maximum_age_in_years}}, socket) do
    {:noreply,
     socket
     |> assign_successor_fees(socket.assigns.fee, maximum_age_in_years)}
  end

  @impl true
  def handle_event("archive", %{"id" => id}, socket) do
    fee = Legal.get_fee!(id)
    {:ok, _} = Legal.archive_fee(fee)

    {:noreply,
     socket
     |> put_flash(:info, "Gebühr erfolgreich archiviert")
     |> push_navigate(to: socket.assigns.navigate)}
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
    fee_params = Enum.into(fee_params, %{
      "club_id" => socket.assigns.fee.club.id
    })

    case Legal.create_fee(fee_params) do
      {:ok, fee} ->
        case create_association(socket, fee) do
          {:ok, _} ->
            {:noreply,
             socket
             |> put_flash(:info, "Gebühr erfolgreich erstellt")
             |> push_navigate(to: socket.assigns.navigate)}

          {:error, _} ->
            {:noreply,
             socket
             |> put_flash(:error, "Gebühr konnte nicht erstellt werden")}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp assign_successor_fees(socket, fee, maximum_age_in_years) do
    assign(socket, :successor_fees, Legal.list_successor_fees(fee, maximum_age_in_years))
  end

  defp create_association(socket, fee) do
    if fee.is_general do
      {:ok, fee}
    else
      # Specific (= non-general) fees (should) always have an association
      # with a certain entity via a polymorphic many_to_many relationship.
      # The concrete data type of this entity is, due to the polymorphic
      # many_to_many relationship, not predefinined.
      # The following code checks all possible "association lists" of the
      # fee if they contain the entity to which the current fee should be
      # "connected". After that has been determined, the many_to_many
      # relationship will be created.
      cond do
        is_list(socket.assigns.fee.departments) ->
          department = Enum.at(socket.assigns.fee.departments, 0)
          Organization.create_department_fee(department, fee)
          {:ok, fee}
        is_list(socket.assigns.fee.equipment) ->
          equipment = Enum.at(socket.assigns.fee.equipment, 0)
          Asset.create_equipment_fee(equipment, fee)
          {:ok, fee}
        is_list(socket.assigns.fee.events) ->
          event = Enum.at(socket.assigns.fee.events, 0)
          Calendar.create_event_fee(event, fee)
          {:ok, fee}
        is_list(socket.assigns.fee.groups) ->
          group = Enum.at(socket.assigns.fee.groups, 0)
          Organization.create_group_fee(group, fee)
          {:ok, fee}
        is_list(socket.assigns.fee.venues) ->
          venue = Enum.at(socket.assigns.fee.venues, 0)
          Asset.create_venue_fee(venue, fee)
          {:ok, fee}
        true ->
          # Immediately delete the fee if no association could be created.
          # Otherwise the fee would be "free floating" and could not be accessed via the UI.
          {:error, _} = Legal.delete_fee(fee)
      end
    end
  end
end
