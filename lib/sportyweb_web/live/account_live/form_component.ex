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
              <div class={
                if @account.id && Account.is_archived?(@account) do
                  "col-span-12 md:col-span-6 opacity-70"
                else
                  "col-span-12 md:col-span-6"
                end
              }>
                <.input
                  field={@form[:account_number]}
                  type="number"
                  label="Kontonummer"
                  phx-change="validate_number"
                  phx-update="ignore"
                  phx-debounce="blur"
                  readonly={@account.id && Account.is_archived?(@account)}
                />
              </div>
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:name]} type="text" label="Name" phx-update="ignore" />
              </div>
              <div class="opacity-70 col-span-12 md:col-span-6">
                <.input field={@form[:class]} type="text" label="Kontoklasse" readonly />
              </div>
              <%= if @action == :new || @account.opening_balance == Money.new(:EUR, 0) && not Enum.any?(@account.entry) do %>
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:opening_balance]} type="number" label="Anfangsbestand (optional)" />
              </div>
              <% end %>
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:archive_date]} type="date" label="Archiviert ab (optional)" />
              </div>
            </.input_grid>
            <.input_grid :if={show_archive_message?(@account)} class="pt-6">
              <div class="col-span-12">
                <div
                  class="bg-amber-100 border border-amber-400 text-amber-800 px-4 py-3 rounded relative"
                  role="alert"
                >
                  Dieses Konto kann nicht gelöscht, sondern nur archiviert werden, denn:
                  <ul class="list-disc pl-4 mb-3">
                    <li :if={Enum.any?(@account.entry)}>
                      Es wird in {Enum.count(@account.entry)} Buchungen verwendet.
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
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Accounting.change_account(account))
     end)}
  end

  @impl true
  def handle_event("validate_number", %{"account" => account_params}, socket) do
    account_class = Accounting.determine_account_class(account_params["account_number"])

    account_params = account_params |> Map.put("class", account_class)

    changeset =
      %Account{}
      |> Accounting.change_account(account_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("validate", %{"account" => account_params}, socket) do
    changeset = Accounting.change_account(socket.assigns.account, account_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"account" => account_params}, socket) do
    save_account(socket, socket.assigns.action, account_params)
  end

  defp save_account(socket, :edit, account_params) do
    account_params =
      Enum.into(account_params, %{
        "balance" => account_params["opening_balance"]
      })
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
    account_params =
      Enum.into(account_params, %{
        "club_id" => socket.assigns.account.club.id,
        "balance" => account_params["opening_balance"]
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
    account.id && !Enum.any?(account.entry)
  end

  defp show_archive_message?(account) do
    account.id && Enum.any?(account.entry) && !Account.is_archived?(account)
  end
end
