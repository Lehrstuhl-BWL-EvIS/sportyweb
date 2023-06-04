defmodule SportywebWeb.FeeLive.FormComponent do
  use SportywebWeb, :live_component
  import Ecto.Changeset

  alias Sportyweb.Asset
  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Asset.Venue
  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event
  alias Sportyweb.Finance
  alias Sportyweb.Finance.Fee
  alias Sportyweb.Organization
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.Group

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
              <div class="col-span-12">
                <.input
                  field={@form[:subsidy_id]}
                  type="select"
                  label="Zuschuss (optional)"
                  options={Finance.list_subsidies(@fee.club_id) |> Enum.map(&{&1.name, &1.id})}
                  prompt="Kein Zuschuss"
                />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12">
                <.input
                  field={@form[:is_for_contact_group_contacts_only]}
                  type="checkbox"
                  label="Soll diese Gebühr nur für Mitglieder einer Kontaktgruppe (z.B. Familie, Ehepartner, Alleinerziehende mit Kindern, etc.) zur Verfügung stehen?"
                />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:minimum_age_in_years]} type="number" label="Mindestalter (optional)" min="0" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:maximum_age_in_years]} type="number" label="Höchstalter (optional)" min="0" />
              </div>

              <div class="col-span-12" :if={Enum.any?(@successor_fee_options)}>
                <.input
                  field={@form[:successor_id]}
                  type="select"
                  label="Nachfolger-Gebühr (optional)"
                  options={@successor_fee_options |> Enum.map(&{&1.name, &1.id})}
                  prompt="Keine Nachfolger-Gebühr"
                />
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

            <.input_grid class="pt-6" :if={show_archive_button?(@fee)}>
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
              :if={show_delete_button?(@fee)}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @fee.id})}
              data-confirm="Unwiderruflich löschen?">
              Löschen
            </.button>
            <.button
              :if={show_archive_button?(@fee)}
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
    changeset = Finance.change_fee(fee)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> assign_successor_fee_options(fee, fee.maximum_age_in_years)}
  end

  @impl true
  def handle_event("validate", %{"fee" => fee_params}, socket) do
    changeset =
      socket.assigns.fee
      |> Finance.change_fee(fee_params)
      |> Map.put(:action, :validate)

    changed_maximum_age_in_years = get_change(changeset, :maximum_age_in_years)
    if changed_maximum_age_in_years do
      # Assigning new successor_fee_options should usually be done in a separate
      # handle_event function that gets called every time a change happens
      # to the value of the :maximum_age_in_years field. This was the case once,
      # but adding a phx-change="..." to the field removed the ability to
      # dynamically validate with this function. This led to some unwanted
      # behaviours (the validation only happend after clicking submit)
      # and was therefore replaced with what you can see here.
      # It is not optimal, because the assignment of new successor_fee_options
      # happens more often than it would with a separate handle_event function,
      # but at least the dynamic validation works (again) and doesn't confuse users.
      # TODO: Link to docs. (Form Binding)
      {:noreply,
       socket
       |> assign_form(changeset)
       |> assign_successor_fee_options(socket.assigns.fee, changed_maximum_age_in_years)}
    else
      {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("save", %{"fee" => fee_params}, socket) do
    save_fee(socket, socket.assigns.action, fee_params)
  end

  @impl true
  def handle_event("archive", %{"id" => id}, socket) do
    fee = Finance.get_fee!(id)
    {:ok, _} = Finance.archive_fee(fee)

    {:noreply,
     socket
     |> put_flash(:info, "Gebühr erfolgreich archiviert")
     |> push_navigate(to: socket.assigns.navigate)}
  end

  defp save_fee(socket, :edit, fee_params) do
    case Finance.update_fee(socket.assigns.fee, fee_params) do
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

    case Finance.create_fee(fee_params) do
      {:ok, fee} ->
        case create_association(fee, socket.assigns.fee_object) do
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

  defp assign_successor_fee_options(socket, fee, maximum_age_in_years) do
    assign(socket, :successor_fee_options, Finance.list_successor_fee_options(fee, maximum_age_in_years))
  end

  defp create_association(fee, _) when fee.is_general do
    # Don't create any association if the fee is a general fee.
    {:ok, fee}
  end

  defp create_association(fee, %Department{} = fee_object) do
    Organization.create_department_fee(fee_object, fee)
    {:ok, fee}
  end

  defp create_association(fee, %Equipment{} = fee_object) do
    Asset.create_equipment_fee(fee_object, fee)
    {:ok, fee}
  end

  defp create_association(fee, %Event{} = fee_object) do
    Calendar.create_event_fee(fee_object, fee)
    {:ok, fee}
  end

  defp create_association(fee, %Group{} = fee_object) do
    Organization.create_group_fee(fee_object, fee)
    {:ok, fee}
  end

  defp create_association(fee, %Venue{} = fee_object) do
    Asset.create_venue_fee(fee_object, fee)
    {:ok, fee}
  end

  defp create_association(fee, _) do
    # Immediately delete the fee if no association could be created.
    # Otherwise the fee would be "free floating", without a fee_object.
    {:error, _} = Finance.delete_fee(fee)
  end

  defp show_delete_button?(fee) do
    fee.id && !(Enum.any?(fee.ancestors) || Enum.any?(fee.contracts))
  end

  defp show_archive_button?(fee) do
    fee.id && (Enum.any?(fee.ancestors) || Enum.any?(fee.contracts)) && !Fee.is_archived?(fee)
  end
end
