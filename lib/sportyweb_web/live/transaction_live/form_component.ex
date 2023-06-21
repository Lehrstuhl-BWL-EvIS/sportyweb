defmodule SportywebWeb.TransactionLive.FormComponent do
  use SportywebWeb, :live_component
  import SportywebWeb.CommonHelper

  alias Sportyweb.Accounting

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.card>
        <.list>
          <:item title="Betrag">
            <%= @transaction.amount %>
          </:item>
          <:item title="Erstellungsdatum">
            <%= format_date_field_dmy(@transaction.creation_date) %>
          </:item>
          <:item title="Kontakt">
            <.link navigate={~p"/contacts/#{@transaction.contract.contact}"} class="text-indigo-600 hover:underline">
              <%= format_string_field(@transaction.contract.contact.name) %>
            </.link>
          </:item>
        </.list>

        <hr class="mt-12 mb-6">

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
                <.input field={@form[:payment_date]} type="date" label="Zahlungsdatum" />
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
    </div>
    """
  end

  @impl true
  def update(%{transaction: transaction} = assigns, socket) do
    changeset = Accounting.change_transaction(transaction)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset =
      socket.assigns.transaction
      |> Accounting.change_transaction(transaction_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
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
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
