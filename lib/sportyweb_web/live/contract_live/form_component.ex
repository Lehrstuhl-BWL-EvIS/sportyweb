defmodule SportywebWeb.ContractLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Finance
  alias Sportyweb.Legal
  alias Sportyweb.Organization
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.Group
  alias Sportyweb.Personal

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
          id="contract-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input_grids>
            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:contact_id]}
                  type="select"
                  label="Kontakt"
                  options={@contact_options |> Enum.map(&{&1.name, &1.id})}
                  prompt="Bitte auswählen"
                  phx-change="update_fee_options"
                />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:fee_id]}
                  type="select"
                  label="Gebühr"
                  options={@fee_options |> Enum.map(&{&1.name, &1.id})}
                  prompt="Bitte auswählen"
                />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:signing_date]} type="date" label="Unterzeichnungsdatum" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:start_date]} type="date" label="Startdatum" />
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
  def update(%{contract: contract} = assigns, socket) do
    changeset = Legal.change_contract(contract)

    contact_options = Personal.list_contract_contact_options(contract, assigns.contract_object)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:contact_options, contact_options)
     |> assign_form(changeset)
     |> assign_fee_options(nil)}
  end

  @impl true
  def handle_event("validate", %{"contract" => contract_params}, socket) do
    changeset =
      socket.assigns.contract
      |> Legal.change_contract(contract_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"contract" => contract_params}, socket) do
    save_contract(socket, socket.assigns.action, contract_params)
  end

  @impl true
  def handle_event("update_fee_options", %{"contract" => %{"contact_id" => contact_id}}, socket) do
    {:noreply, assign_fee_options(socket, contact_id)}
  end

  defp save_contract(socket, :edit, contract_params) do
    case Legal.update_contract(socket.assigns.contract, contract_params) do
      {:ok, _contract} ->
        {:noreply,
         socket
         |> put_flash(:info, "Mitgliedschaftsvertrag erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_contract(socket, :new, contract_params) do
    contract_params = Enum.into(contract_params, %{
      "club_id" => socket.assigns.contract.club.id
    })

    case Legal.create_contract(contract_params) do
      {:ok, contract} ->
        case create_association(contract, socket.assigns.contract_object) do
          {:ok, _} ->
            {:noreply,
             socket
             |> put_flash(:info, "Mitgliedschaftsvertrag erfolgreich erstellt")
             |> push_navigate(to: socket.assigns.navigate)}

          {:error, _} ->
            {:noreply,
             socket
             |> put_flash(:error, "Mitgliedschaftsvertrag konnte nicht erstellt werden")}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp assign_fee_options(socket, contact_id) do
    assign(socket, :fee_options, Finance.list_contract_fee_options(socket.assigns.contract_object, contact_id))
  end

  defp create_association(contract, %Club{} = contract_object) do
    Organization.create_club_contract(contract_object, contract)
    {:ok, contract}
  end

  defp create_association(contract, %Department{} = contract_object) do
    Organization.create_department_contract(contract_object, contract)
    {:ok, contract}
  end

  defp create_association(contract, %Group{} = contract_object) do
    Organization.create_group_contract(contract_object, contract)
    {:ok, contract}
  end

  defp create_association(contract, _) do
    # Immediately delete the contract if no association could be created.
    # Otherwise the contract would be "free floating", without a contract_object.
    {:error, _} = Legal.delete_contract(contract)
  end
end
