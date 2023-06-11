defmodule SportywebWeb.TransactionLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Accounting

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
          id="transaction-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input_grids>
            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:name]} type="text" label="Name" />
              </div>

              <div class="col-span-12">
                <.input field={@form[:amount]} type="text" label="Betrag in Euro" />
                <.input_description>Das €-Zeichen kann, muss aber nicht angegeben werden.</.input_description>
              </div>
            </.input_grid>

            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:creation_date]} type="date" label="Erstellungsdatum" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:payment_date]} type="date" label="Zahlungsdatum" />
              </div>
            </.input_grid>
          </.input_grids>

          <:actions>
            <.button phx-disable-with="Speichern...">Speichern</.button>
            <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
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
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
