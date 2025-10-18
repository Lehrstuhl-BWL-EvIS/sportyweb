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
              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:account_number]}
                  type="number"
                  label="Kontonummer"
                  phx-change="validate_number"
                  phx-update="ignore"
                />
              </div>
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:name]} type="text" label="Name" phx-update="ignore" />
              </div>
              <div class="col-span-12">
                <.input field={@form[:class]} type="text" label="Kontoklasse" readonly />
              </div>
            </.input_grid>
          </.input_grids>
          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
            </div>
            <.button
              :if={@account.id}
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
    account_params = determine_class(account_params)

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
        "club_id" => socket.assigns.account.club.id
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

  # Determines the class of an account according to the first digit of it's account number
  defp determine_class(account_params) do
    case String.first(account_params["account_number"]) do
      "0" ->
        account_params |> Map.put("class", "Anlagevermögen")

      "1" ->
        account_params |> Map.put("class", "Umlaufvermögen")

      "2" ->
        account_params |> Map.put("class", "Eigen-/Fremdkapital")

      "3" ->
        account_params |> Map.put("class", "Fremdkapital")

      "4" ->
        account_params |> Map.put("class", "Einnahmen")

      "5" ->
        account_params |> Map.put("class", "Ausgaben")

      "6" ->
        account_params |> Map.put("class", "Ausgaben")

      "7" ->
        account_params |> Map.put("class", "Weitere Einnahmen und Ausgaben")

      "8" ->
        account_params |> Map.put("class", "")

      "9" ->
        account_params
        |> Map.put("class", "Vortrags-, Kapital-, Korrektur- und statistische Konten ")
    end
  end
end
