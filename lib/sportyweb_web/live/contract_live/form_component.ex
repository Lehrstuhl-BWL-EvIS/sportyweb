defmodule SportywebWeb.ContractLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Legal
  alias Sportyweb.Organization
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
                  options={@contacts |> Enum.map(&{&1.name, &1.id})}
                  prompt="Bitte auswählen"
                  phx-change="update_fee_options"
                />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:fee_id]}
                  type="select"
                  label="Gebühr"
                  options={@fees |> Enum.map(&{&1.name, &1.id})}
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
              <.link navigate={@navigate} class="mx-2 py-1 px-1 text-sm font-semibold hover:underline">
                Abbrechen
              </.link>
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

    contacts = Personal.list_contacts(contract.club_id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:contacts, contacts)
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
    {:noreply,
     socket
     |> assign_fee_options(contact_id)}
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
        case create_association(socket, contract) do
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

  defp assign_fee_options(socket, contact) do
    assign(socket, :fees, Legal.list_contact_fee_options(contact))
  end

  defp create_association(socket, contract) do
    # Contracts (should) always have an association
    # with a certain entity via a polymorphic many_to_many relationship.
    # The concrete data type of this entity is, due to the polymorphic
    # many_to_many relationship, not predefinined.
    # The following code checks all possible "association lists" of the
    # contract if they contain the entity to which the current contract should be
    # "connected". After that has been determined, the many_to_many
    # relationship will be created.
    cond do
      is_list(socket.assigns.contract.clubs) ->
        club = Enum.at(socket.assigns.contract.clubs, 0)
        Organization.create_club_contract(club, contract)
        {:ok, contract}
      is_list(socket.assigns.contract.departments) ->
        department = Enum.at(socket.assigns.contract.departments, 0)
        Organization.create_department_contract(department, contract)
        {:ok, contract}
      is_list(socket.assigns.contract.groups) ->
        group = Enum.at(socket.assigns.contract.groups, 0)
        Organization.create_group_contract(group, contract)
        {:ok, contract}
      true ->
        # Immediately delete the contract if no association could be created.
        # Otherwise the contract would be "free floating" and could not be accessed via the UI.
        {:error, _} = Legal.delete_contract(contract)
    end
  end
end
