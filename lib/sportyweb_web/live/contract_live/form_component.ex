defmodule SportywebWeb.ContractLive.FormComponent do
  use SportywebWeb, :live_component

  alias SportywebWeb.CommonHelper

  alias Ecto.Changeset
  alias Sportyweb.Finance
  alias Sportyweb.Legal
  alias Sportyweb.Organization
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact

  @impl true
  def render(assigns) do
    ~H"""
    <div>
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
              <.select_or_read_only
                read_only={@contract.id != nil}
                form={@form}
                field={:contact_id}
                options={@contacts}
                label="Kontakt"
                promt="Bitte auswählen"
                print_function={&print_contact(&1)}
              />
            </div>

            <div class="col-span-12 md:col-span-3">
              <.select_or_read_only
                read_only={@contract.id != nil}
                form={@form}
                field={:department_id}
                options={@departments}
                label="Mit Abteilung"
                promt="-"
                print_function={& &1.name}
              />
            </div>
            <div class="col-span-12 md:col-span-3">
              <.select_or_read_only
                read_only={@contract.id != nil}
                form={@form}
                field={:group_id}
                options={@groups}
                label="Mit Gruppe"
                promt="-"
                print_function={& &1.name}
              />
            </div>

            <div class="col-span-12 md:col-span-6">
              <.select_or_read_only
                read_only={@contract.id != nil}
                form={@form}
                field={:fee_id}
                options={@fees}
                label="Gebühr"
                promt="Bitte auswählen"
                print_function={& &1.name}
              />
            </div>

            <div class="col-span-12 md:col-span-6">
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:signing_date]} type="date" label="Unterzeichnungsdatum" />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:start_date]} type="date" label="Vertragsbeginn" />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:first_billing_date]} type="date" label="Erste Abrechnung" />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:termination_date]} type="date" label="Kündigungsdatum" />
            </div>

            <div class="col-span-12 md:col-span-4">
              <.input field={@form[:archive_date]} type="date" label="Archiviert ab" />
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
    </div>
    """
  end

  def select_or_read_only(assigns) do
    ~H"""
    <div class={
      if @read_only do
        "hidden"
      else
        ""
      end
    }>
      <.input
        field={@form[@field]}
        type="select"
        label={"#{@label} (#{length(@options)})"}
        options={@options |> Enum.map(&{@print_function.(&1), &1.id})}
        prompt={@promt}
      />
    </div>
    <div :if={@read_only}>
      <.label>{@label}</.label>
      {print_wanted_element(@options, @form[@field].value, @print_function)}
      <.error :for={msg <- Enum.map(@form[@field].errors, &translate_error(&1))}>{msg}</.error>
    </div>
    """
  end

  @impl true
  def update(%{contract: contract} = assigns, socket) do
    club_id = contract.club.id

    contacts =
      case contract.contact do
        nil -> Personal.list_contacts(club_id)
        _ -> [contract.contact]
      end

    departments =
      case contract.partner_department do
        nil -> Organization.list_departments(club_id, :fees)
        _ -> [contract.partner_department]
      end

    groups =
      case contract.partner_group do
        nil -> []
        _ -> [contract.partner_group]
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(club: contract.club)
     |> assign(departments: departments)
     |> assign(groups: groups)
     |> assign(contacts: contacts)
     |> assign(:form, to_form(Legal.change_contract(contract)))
     |> update_fee_options()}
  end

  @impl true
  def handle_event("validate", %{"contract" => contract_params}, socket) do
    changeset = Legal.change_contract(socket.assigns.contract, contract_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"contract" => contract_params}, socket) do
    save_contract(socket, socket.assigns.action, contract_params)
  end

  defp save_contract(socket, :edit, contract_params) do
    case Legal.update_contract(socket.assigns.contract, contract_params) do
      {:ok, _contract} ->
        {:noreply,
         socket
         |> put_flash(:info, "Mitgliedschaftsvertrag erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_contract(socket, :new, contract_params) do
    contract_params =
      Enum.into(contract_params, %{
        "club_id" => socket.assigns.contract.club.id
      })

    case Legal.create_contract(contract_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Mitgliedschaftsvertrag erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp update_fee_options(socket) do
    group =
      case get_form_value(socket, :group_id) do
        nil -> nil
        group_id -> find_by_id(socket.assigns.groups, group_id)
      end

    department =
      case get_form_value(socket, :department_id) do
        nil -> nil
        department_id -> find_by_id(socket.assigns.departments, department_id)
      end

    fees =
      cond do
        group != nil ->
          group.fees

        department != nil ->
          department.fees

        true ->
          Finance.list_general_fees(socket.assigns.club.id, "club")
      end

    assign(socket, fees: fees)
  end

  def get_form_value(socket, field) do
    get_value(socket.assigns.form.source, field)
  end

  def get_value(%Changeset{} = changeset, field) do
    case Changeset.get_change(changeset, field) do
      nil -> Changeset.get_field(changeset, field)
      value -> value
    end
  end

  def print_contact(%Contact{} = contact) do
    if Contact.is_person?(contact) do
      age_in_years = Contact.age_in_years(contact)
      gender = CommonHelper.get_key_for_value(Contact.get_valid_genders(), contact.person_gender)
      "#{contact.name} (#{age_in_years}, #{gender})"
    else
      contact.name
    end
  end

  def find_by_id(elements, wanted_id) do
    Enum.find(elements, fn e -> e.id == wanted_id end)
  end

  def print_wanted_element(elements, wanted_id, print_function) do
    res =
      case find_by_id(elements, wanted_id) do
        nil -> nil
        elements -> print_function.(elements)
      end

    CommonHelper.format_string_field(res)
  end
end
