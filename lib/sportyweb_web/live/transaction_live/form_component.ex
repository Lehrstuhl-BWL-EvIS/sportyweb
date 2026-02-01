defmodule SportywebWeb.TransactionLive.FormComponent do
  use SportywebWeb, :live_component
  import SportywebWeb.CommonHelper

  alias Sportyweb.Accounting
  alias Sportyweb.Personal
  alias Sportyweb.Legal

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
                  <.input
                    field={@form[:name]}
                    type="text"
                    label="Name"
                    phx-change="validate"
                    phx-update="ignore"
                  />
                </div>
                <div class="col-span-12 md:col-span-6">
                  <.input field={@form[:receipt_number]} type="text" label="Belegnummer (optional)" />
                </div>
                <div class="col-span-12 md:col-span-6">
                  <.input
                    field={@form[:account_id]}
                    type="select"
                    label="Finanzkonto"
                    options={
                      for a <- @financial_account_options do
                        {"#{a.account_number} #{a.name}", a.id}
                      end
                    }
                  />
                </div>
                <div class="col-span-12 md:col-span-6">
                  <.input field={@form[:payment_date]} type="date" label="Zahlungsdatum" />
                </div>
                <div class="col-span-12 md:col-span-6">
                  <.input field={@form[:due_date]} type="date" label="Fälligkeitsdatum (optional)" />
                </div>
              </.input_grid>
              <.input_grid class="pt-6">
                <div class="col-span-12">
                  <.input
                    field={@form[:contact_id]}
                    phx-change="change_contact"
                    type="select"
                    label="Kontakt (optional)"
                    options={@contact_options |> Enum.map(&{&1.name, &1.id})}
                    prompt="Kein Kontakt"
                  />
                </div>
                <div class="col-span-12">
                  <.input
                    field={@form[:contract_id]}
                    type="select"
                    label="Mitgliedschaftsvertrag (optional)"
                    disabled={not @contract_enabled}
                    options={@contract_options |> Enum.map(&{&1.fee.name, &1.id})}
                    prompt="Kein Vertrag"
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
                <div class="col-span-12">
                  <.input
                    field={@form[:name]}
                    type="text"
                    label="Name"
                    phx-change="validate"
                    phx-update="ignore"
                  />
                </div>
                <div class="col-span-12 md:col-span-6">
                  <.input field={@form[:amount]} type="text" label="Betrag" phx-update="ignore" />
                  <.input_description>
                    Das €-Zeichen kann, muss aber nicht angegeben werden.
                  </.input_description>
                </div>
                <div class="col-span-12 md:col-span-6">
                  <.input field={@form[:receipt_number]} type="text" label="Belegnummer (optional)" />
                </div>
                <div class="col-span-12 md:col-span-6">
                  <.input field={@form[:payment_date]} type="date" label="Zahlungsdatum" />
                </div>
                <div class="col-span-12 md:col-span-6">
                  <.input field={@form[:due_date]} type="date" label="Fälligkeitsdatum (optional)" />
                </div>
                <div class="col-span-12">
                  <.input
                    field={@form[:account_id]}
                    type="select"
                    label="Finanzkonto"
                    options={
                      for a <- @financial_account_options do
                        {"#{a.account_number} #{a.name}", a.id}
                      end
                    }
                  />
                </div>
                <div class="col-span-12">
                  <.input
                    field={@form[:type]}
                    type="select"
                    label="Art"
                    options={["Einnahme", "Ausgabe"]}
                  />
                </div>
              </.input_grid>
              <.input_grid class="pt-6">
                <div class="col-span-12">
                  <.input
                    field={@form[:contact_id]}
                    phx-change="change_contact"
                    type="select"
                    label="Kontakt (optional)"
                    options={@contact_options |> Enum.map(&{&1.name, &1.id})}
                    prompt="Kein Kontakt"
                  />
                </div>
                <div class="col-span-12">
                  <.input
                    field={@form[:contract_id]}
                    type="select"
                    label="Mitgliedschaftsvertrag (optional)"
                    disabled={not @contract_enabled}
                    options={@contract_options |> Enum.map(&{&1.fee.name, &1.id})}
                    prompt="Kein Vertrag"
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
     |> assign(
       :financial_account_options,
       Accounting.list_financial_accounts(assigns.transaction.club.id)
     )
     |> assign_new(:form, fn ->
       to_form(Accounting.change_transaction(transaction))
     end)}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset = Accounting.change_transaction(socket.assigns.transaction, transaction_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("change_contact", %{"transaction" => %{"contact_id" => contact}}, socket) do
    if contact in [nil, ""] do
      {:noreply,
       socket
       |> assign(:contract_options, [])
       |> assign(:contract_enabled, false)}
    else
      contract_options = Legal.list_contact_contract_options(contact, [:fee])

      {:noreply,
       socket
       |> assign(:contract_options, contract_options)
       |> assign(:contract_enabled, true)}
    end
  end

  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    save_transaction(socket, socket.assigns.action, transaction_params)
  end

  defp save_transaction(socket, :edit, transaction_params) do
    case Accounting.update_transaction_and_entry(socket.assigns.transaction, transaction_params) do
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
        "club_id" => socket.assigns.transaction.club.id
      })

    case Accounting.create_transaction_and_entry(transaction_params) do
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
