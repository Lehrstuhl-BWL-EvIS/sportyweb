defmodule SportywebWeb.TransactionLive.FormComponent do
  use SportywebWeb, :live_component
  import SportywebWeb.CommonHelper

  alias Sportyweb.Accounting
  alias Sportyweb.Personal

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <%= if @action == :edit do %>
        <.card>
          <.list>
            <:item title="Art">
              {format_string_field(@transaction.type)}
            </:item>

            <:item title="Betrag">
              {@transaction.amount}
            </:item>

            <:item title="Erstellungsdatum">
              {format_date_field_dmy(@transaction.creation_date)}
            </:item>
          </.list>
          <hr class="mt-12 mb-6" />
          <.simple_form
            for={@form}
            id="transaction-form"
            phx-target={@myself}
            phx-change="validate"
            phx-submit="save"
          >
            <.input_grids>
              <.input_grid>
                <div class="col-span-12">
                  <.input field={@form[:receipt_number]} type="text" label="Belegnummer (optional)" />
                </div>
                <div class="col-span-12">
                  <.input field={@form[:payment_date]} type="date" label="Zahlungsdatum" />
                </div>
                <div class="col-span-12">
                  <.input
                    field={@form[:contact_id]}
                    type="select"
                    label="Kontakt (optional)"
                    options={@contact_options |> Enum.map(&{&1.name, &1.id})}
                    prompt="Kein Kontakt"
                  />
                </div>
              </.input_grid>
            </.input_grids>
            <:actions>
              <div>
                <.button phx-disable-with="Speichern...">Speichern</.button>

                <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
              </div>
              <.button
                :if={@transaction.id}
                class="bg-rose-700 hover:bg-rose-800"
                phx-click={JS.push("delete", value: %{id: @transaction.id})}
                data-confirm="Unwiderruflich löschen?"
              >
                Löschen
              </.button>
            </:actions>
          </.simple_form>
        </.card>
      <% end %>

      <%= if @action == :new do %>
        <.card>
          <.simple_form
            for={@form}
            id="transaction-form"
            phx-target={@myself}
            phx-change="validate"
            phx-submit="save"
          >
            <.input_grids>
              <.input_grid>
                <div class="col-span-12 md:col-span-6">
                  <.input
                    field={@form[:name]}
                    type="text"
                    label="Name"
                    phx-change="validate"
                    phx-update="ignore"
                  />
                </div>
                <div class="col-span-12 md:col-span-6">
                  <.input field={@form[:amount]} type="number" label="Betrag" phx-update="ignore" />
                </div>
                <div class="col-span-12 md:col-span-6">
                  <.input field={@form[:payment_date]} type="date" label="Zahlungsdatum" />
                </div>
                <div class="col-span-12 md:col-span-6">
                  <.input field={@form[:receipt_number]} type="text" label="Belegnummer (optional)" />
                </div>
                <div class="col-span-12">
                  <.input
                    field={@form[:contact_id]}
                    type="select"
                    label="Kontakt (optional)"
                    options={@contact_options |> Enum.map(&{&1.name, &1.id})}
                    prompt="Kein Kontakt"
                  />
                </div>
                <div class="col-span-12">
                  <.input
                    field={@form[:type]}
                    type="select"
                    label="Art"
                    options={["Einnahme", "Ausgabe", "Umbuchung"]}
                  />
                </div>
              </.input_grid>
            </.input_grids>
            <:actions>
              <div>
                <.button phx-disable-with="Speichern...">Speichern</.button>

                <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
              </div>
            </:actions>
          </.simple_form>
        </.card>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(%{transaction: transaction} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:contact_options, Personal.list_contacts(assigns.transaction.club.id))
     |> assign_new(:form, fn ->
       to_form(Accounting.change_transaction(transaction))
     end)}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset = Accounting.change_transaction(socket.assigns.transaction, transaction_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    save_transaction(socket, socket.assigns.action, transaction_params)
  end

  defp save_transaction(socket, :edit, transaction_params) do
    case Accounting.update_transaction(socket.assigns.transaction, transaction_params) do
      {:ok, _transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_transaction(socket, :new, transaction_params) do
    transaction_params =
      Enum.into(transaction_params, %{
        "club_id" => socket.assigns.transaction.club.id,
        "creation_date" => Date.utc_today()
      })

    case Accounting.create_transaction(transaction_params) do
      {:ok, _transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
