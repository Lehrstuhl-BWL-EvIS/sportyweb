defmodule SportywebWeb.AccountLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Accounting
  alias Sportyweb.Accounting.Account

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
          id="account-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input_grids>
            <.input_grid>
              <%= if @action == :new do %>
                <div class="col-span-12 md:col-span-6">
                  <.input
                    field={@form[:account_number]}
                    type="number"
                    label="Kontonummer"
                    phx-change="validate_number"
                  />
                </div>
              <% end %>
              <%= if @action == :edit do %>
                <div class="col-span-12 md:col-span-6 opacity-70">
                  <.input
                    field={@form[:account_number]}
                    type="number"
                    label="Kontonummer"
                    phx-change="validate_number"
                    readonly
                  />
                </div>
              <% end %>
              <div class="opacity-70 col-span-12 md:col-span-6">
                <.input field={@form[:class]} type="text" label="Kontenklasse" readonly />
              </div>
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:name]} type="text" label="Name" phx-update="ignore" />
              </div>
              <%= if @action == :new do %>
                <div class={
                  if @activate_account_type do
                    "col-span-12 md:col-span-6"
                  else
                    "col-span-12 md:col-span-6 opacity-70"
                  end
                }>
                  <.input
                    field={@form[:type]}
                    type="select"
                    label="Art"
                    options={Account.type_options()}
                    disabled={not @activate_account_type}
                  />
                </div>
              <% else %>
                <div class="col-span-12 md:col-span-6 opacity-70">
                  <.input
                    field={@form[:type]}
                    type="select"
                    label="Art"
                    options={Account.type_options()}
                    disabled
                  />
                </div>
              <% end %>
              <%= if @activate_opening_balance == true do %>
                <div class="col-span-12 md:col-span-6">
                  <.input field={@form[:opening_balance]} type="text" label="Anfangsbestand" />
                  <.input_description>
                    Das €-Zeichen kann, muss aber nicht angegeben werden.
                  </.input_description>
                </div>
              <% else %>
                <div class="opacity-70 col-span-12 md:col-span-6">
                  <.input field={@form[:opening_balance]} type="text" label="Anfangsbestand" readonly />
                  <.input_description>
                    Das €-Zeichen kann, muss aber nicht angegeben werden.
                  </.input_description>
                </div>
              <% end %>
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:archive_date]} type="date" label="Archiviert ab (optional)" />
              </div>
            </.input_grid>
            <%= if @is_relevant_for_income_statement do %>
              <.input_grid class="pt-6">
                <div class="col-span-12">
                  <.input
                    field={@form[:is_relevant_for_income_statement]}
                    type="checkbox"
                    label="Soll dieses Konto in der EÜR berücksichtigt werden?"
                  />
                </div>
              </.input_grid>
            <% end %>
            <.input_grid :if={show_archive_message?(@account)} class="pt-6">
              <div class="col-span-12">
                <div
                  class="bg-amber-100 border border-amber-400 text-amber-800 px-4 py-3 rounded relative"
                  role="alert"
                >
                  Dieses Konto kann nicht gelöscht, sondern nur archiviert werden, denn:
                  <ul class="list-disc pl-4 mb-3">
                    <li :if={Enum.any?(@account.entries)}>
                      Es wird in {Enum.count(@account.entries)} Buchungen verwendet.
                    </li>
                  </ul>
                  Zur Archivierung bitte das gewünschte Datum im Feld "Archiviert ab" eintragen und "Speichern" klicken.
                </div>
              </div>
            </.input_grid>
            <.input_grid :if={@account.id && Account.is_archived?(@account)} class="pt-6">
              <div class="col-span-12">
                <div
                  class="bg-amber-100 border border-amber-400 text-amber-800 px-4 py-3 rounded relative"
                  role="alert"
                >
                  Dieses Konto ist derzeit archiviert.
                  Wird das Datum im Feld "Archiviert ab" gelöscht, oder durch ein Zukünftiges ersetzt,
                  lässt sich die Archivierung komplett bzw. temporär aufheben.
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
              :if={show_delete_button?(@account)}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @account.id})}
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
  def update(%{account: account} = assigns, socket) do
    is_relevant_for_income_statement = Account.is_relevant_for_income_statement?(account.type)
    activate_account_type = Account.activate_account_type?(account.class)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Accounting.change_account(account))
     end)
     |> assign(:is_relevant_for_income_statement, is_relevant_for_income_statement)
     |> assign(:activate_account_type, activate_account_type)}
  end

  @impl true
  def handle_event("validate_number", %{"account" => account_params}, socket) do
    account_class = Accounting.determine_account_class(account_params["account_number"])

    account_params = account_params |> Map.put("class", account_class)

    account_params =
      account_params
      |> Map.put(
        "type",
        Accounting.determine_account_type(account_params["class"], account_params["type"])
      )

    changeset =
      %Account{}
      |> Accounting.change_account(account_params)
      |> Map.put(:action, :insert)

    is_relevant_for_income_statement =
      Account.is_relevant_for_income_statement?(account_params["type"])

    activate_account_type =
      Account.activate_account_type?(account_params["class"])

    activate_opening_balance = Account.activate_opening_balance?(account_params["type"])

    {:noreply,
     socket
     |> assign(form: to_form(changeset, action: :validate))
     |> assign(:activate_opening_balance, activate_opening_balance)
     |> assign(:is_relevant_for_income_statement, is_relevant_for_income_statement)
     |> assign(:activate_account_type, activate_account_type)}
  end

  @impl true
  def handle_event("validate", %{"account" => account_params}, socket) do
    account_params =
      if socket.assigns.action == :new do
        account_params
        |> Map.put(
          "type",
          Accounting.determine_account_type(account_params["class"], account_params["type"])
        )
      else
        account_params
      end

    if socket.assigns.action == :new do
      is_relevant_for_income_statement =
        Account.is_relevant_for_income_statement?(account_params["type"])

      activate_opening_balance = Account.activate_opening_balance?(account_params["type"])

      changeset = Accounting.change_account(socket.assigns.account, account_params)

      {:noreply,
       socket
       |> assign(form: to_form(changeset, action: :validate))
       |> assign(:is_relevant_for_income_statement, is_relevant_for_income_statement)
       |> assign(:activate_opening_balance, activate_opening_balance)}
    else
      changeset = Accounting.change_account(socket.assigns.account, account_params)

      {:noreply,
       socket
       |> assign(form: to_form(changeset, action: :validate))}
    end
  end

  def handle_event("save", %{"account" => account_params}, socket) do
    save_account(socket, socket.assigns.action, account_params)
  end

  defp save_account(socket, :edit, account_params) do
    case Accounting.update_account(socket.assigns.account, account_params) do
      {:ok, _account} ->
        {:noreply,
         socket
         |> put_flash(:info, "Konto erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_account(socket, :new, account_params) do
    account_type =
      Accounting.determine_account_type(account_params["class"], account_params["type"])

    account_params =
      Enum.into(account_params, %{
        "club_id" => socket.assigns.account.club.id,
        "type" => account_type
      })

    case Accounting.create_account(account_params) do
      {:ok, _account} ->
        {:noreply,
         socket
         |> put_flash(:info, "Konto erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp show_delete_button?(account) do
    account.id && !Enum.any?(account.entries)
  end

  defp show_archive_message?(account) do
    account.id && Enum.any?(account.entries) && !Account.is_archived?(account)
  end
end
