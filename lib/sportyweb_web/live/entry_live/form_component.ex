defmodule SportywebWeb.EntryLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Accounting
  alias Sportyweb.Accounting.Entry

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        for={@form}
        id="entry-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.card>
          <.input_grids>
            <.input_grid>
              <div class="col-span-12">
                <.input
                  field={@form[:account_id]}
                  type="select"
                  label="Konto"
                  options={
                    for a <- @account_options do
                      {"#{a.account_number} #{a.name}", a.id}
                    end
                  }
                />
              </div>
              <div class="col-span-12">
                <%= if @action == :edit do %>
                  <.input
                    field={@form[:amount]}
                    type="text"
                    label="Betrag"
                    value={@entry.amount.amount}
                    phx-update="ignore"
                  />
                  <.input_description>
                    Das €-Zeichen kann, muss aber nicht angegeben werden.
                  </.input_description>
                <% else %>
                  <.input
                    field={@form[:amount]}
                    type="text"
                    label="Betrag"
                    value={@entry.amount}
                    phx-update="ignore"
                  />
                  <.input_description>
                    Das €-Zeichen kann, muss aber nicht angegeben werden.
                  </.input_description>
                <% end %>
              </div>
              <div class="col-span-12">
                <.input
                  field={@form[:sphere]}
                  type="select"
                  label="Sphäre"
                  options={Entry.sphere_options()}
                />
              </div>
            </.input_grid>
          </.input_grids>
        </.card>
        <:actions>
          <div>
            <.button phx-disable-with="Speichern...">Speichern</.button>

            <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
          </div>
          <%= if @action == :edit do %>
            <.button
              :if={@entry.id}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @entry.id})}
              data-confirm="Unwiderruflich löschen?"
            >
              Löschen
            </.button>
          <% end %>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{entry: entry} = assigns, socket) do
    accounts = Accounting.determine_usable_accounts(assigns.entry.transaction.type)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       :account_options,
       accounts |> Accounting.list_accounts(assigns.entry.transaction.club.id)
     )
     |> assign_new(:form, fn ->
       to_form(Accounting.change_entry(entry))
     end)}
  end

  @impl true
  def handle_event("validate", %{"entry" => entry_params}, socket) do
    changeset = Accounting.change_entry(socket.assigns.entry, entry_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"entry" => entry_params}, socket) do
    save_entry(socket, socket.assigns.action, entry_params)
  end

  defp save_entry(socket, :edit, entry_params) do
    case Accounting.update_entry(socket.assigns.entry, entry_params) do
      {:ok, _entry} ->
        {:noreply,
         socket
         |> put_flash(:info, "Entry updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_entry(socket, :new, entry_params) do
    account = Accounting.get_account!(entry_params["account_id"])

    entry_type =
      Accounting.determine_entry_type(socket.assigns.entry.transaction.type, account.type)

    entry_params =
      Enum.into(entry_params, %{
        "transaction_id" => socket.assigns.entry.transaction.id,
        "type" => entry_type
      })

    case Accounting.create_entry(entry_params) do
      {:ok, _entry} ->
        {:noreply,
         socket
         |> put_flash(:info, "Entry created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
