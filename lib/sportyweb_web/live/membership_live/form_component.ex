defmodule SportywebWeb.Membership.FormComponent do
  use SportywebWeb, :live_component

  alias Ecto.Changeset
  alias Sportyweb.Finance
  alias Sportyweb.Organization
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.Membership
  alias Sportyweb.Legal.Contract
  alias SportywebWeb.CommonHelper

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="membership-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input_grids>
          <.input_grid>
            <div class="col-span-12 md:col-span-6">
              <.select_or_read_only
                read_only={@membership.id != nil}
                form={@form}
                field={:contact_id}
                options={@contacts}
                label="Kontakt"
                promt="Bitte auswählen"
                print_function={&print_contract(&1)}
              />
            </div>
            <div :if={@duplicated_membership_error != nil} class="col-span-12 md:col-span-6">
              <.warn>
                Es besteht bereits eine Mitgliedschaft von {@duplicated_membership_error.contact_name} in {@duplicated_membership_error.object_name}
              </.warn>
              <.button type="button">
                <.link navigate={~p"/memberships/#{@duplicated_membership_error.other_id}/edit"}>
                  Zur bestehenden Mitgliedschaft
                </.link>
              </.button>
            </div>
          </.input_grid>

          <.input_grid>
            <div class="col-span-12 md:col-span-6">
              <.select_or_read_only
                read_only={@membership.id != nil}
                form={@form}
                field={:department_id}
                options={@departments}
                label="Abteilung"
                promt="-"
                print_function={& &1.name}
              />
            </div>
            <div class="col-span-12 md:col-span-6">
              <.select_or_read_only
                read_only={@membership.id != nil}
                form={@form}
                field={:group_id}
                options={@groups}
                label="Gruppe"
                promt="-"
                print_function={& &1.name}
              />
            </div>

            <div class="col-span-12 md:col-span-3">
              <.input field={@form[:start_date]} type="date" label="Startdatum" />
            </div>
            <div class="col-span-12 md:col-span-3">
              <.input field={@form[:termination_date]} type="date" label="Enddatum" />
            </div>
            <div class="col-span-12 md:col-span-3">
              <.input
                field={@form[:state]}
                type="select"
                label="Status"
                options={Membership.get_valid_states()}
                prompt="Bitte auswählen"
              />
            </div>
          </.input_grid>

          <.input_grid>
            <div class="col-span-12 md:col-span-6">
              <.header level="5">
                Beiträge
              </.header>
            </div>
            <.inputs_for :let={f_contract} field={@form[:contracts]}>
              <div class="col-span-12 md:col-span-12">
                <.contract_line
                  parent={@myself}
                  contract={f_contract}
                  contract_warnings={@contract_warnings}
                  fees={@fees}
                  contact={find_by_id(@contacts, @form[:contact_id].value)}
                />
              </div>
            </.inputs_for>
            <.button
              class="grow-0 text-green-700 bg-inherit hover:text-green-800 hover:bg-inherit"
              type="button"
              phx-target={@myself}
              phx-click="add-contract"
            >
              <.icon name="hero-plus-circle" />
            </.button>
          </.input_grid>
          <.input_grid></.input_grid>
        </.input_grids>

        <:actions>
          <div>
            <.button phx-disable-with="Speichern...">Speichern</.button>
            <.cancel_button navigate={
              if @membership.id,
                do: ~p"/memberships/#{@membership}",
                else: ~p"/clubs/#{@club}/memberships"
            }>
              Abbrechen
            </.cancel_button>
          </div>
          <.button
            :if={@club.id}
            class="bg-rose-700 hover:bg-rose-800"
            phx-click={JS.push("delete", value: %{id: @membership.id})}
            data-confirm="Unwiderruflich löschen?"
          >
            Löschen
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  attr :read_only, :boolean
  attr :form, :any
  attr :field, :any
  attr :options, :any
  attr :label, :string
  attr :promt, :string
  attr :print_function, :any

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

  attr :fees, :any
  attr :contract, :any
  attr :parent, :any
  attr :contact, :any
  attr :contract_warnings, :any

  def contract_line(assigns) do
    assigns =
      assign(
        assigns,
        :deleted,
        Phoenix.HTML.Form.input_value(assigns.contract, :deleted) == true
      )

    ~H"""
    <div class={if(@deleted, do: "opacity-50")}>
      <.input_grid>
        <input
          type="hidden"
          name={Phoenix.HTML.Form.input_name(@contract, :delete)}
          value={to_string(Phoenix.HTML.Form.input_value(@contract, :delete))}
        />
        <div class="hidden">
          <.input field={@contract[:club_id]} type="text" />
          <.input field={@contract[:contact_id]} type="text" />
          <.input field={@contract[:deleted]} type="checkbox" />
        </div>
        <div class="col-span-12 md:col-span-2">
          <.input field={@contract[:start_date]} type="date" label="Ab" />
        </div>
        <div class="col-span-12 md:col-span-2">
          <.input field={@contract[:termination_date]} type="date" label="Bis" />
        </div>
        <div class="col-span-12 md:col-span-5">
          <.input
            field={@contract[:fee_id]}
            type="select"
            label={"Gebühr (#{length(@fees)})"}
            options={@fees |> Enum.map(&{&1.name, &1.id})}
            prompt="Bitte auswählen"
          />
        </div>
        <div class="col-span-12 md:col-span-2">
          <.input field={@contract[:signing_date]} type="date" label="Unterzeichnungsdatum" />
        </div>
        <div class="col-span-12 md:col-span-1">
          <.button
            class="grow-0 text-red-700 bg-inherit hover:text-red-800 hover:bg-inherit"
            type="button"
            phx-target={@parent}
            phx-click="remove-contract"
            phx-value-index={@contract.index}
          >
            <.icon name="hero-minus-circle" />
          </.button>
        </div>
        <div :if={@contract_warnings[@contract.index] != nil} class="col-span-12 md:col-span-12">
          <div :for={warning <- @contract_warnings[@contract.index]} class="flex">
            <.warn>
              {warning.hint}
            </.warn>
            <.button
              :if={warning.action != nil}
              type="button"
              phx-target={@parent}
              phx-click={
                JS.push("apply-contract-action",
                  value: %{
                    key: warning.action.key,
                    new_value: warning.action.new_value,
                    contract: @contract.index
                  }
                )
              }
            >
              {print_contract_action(warning.action)}
            </.button>
          </div>
        </div>
      </.input_grid>
    </div>
    """
  end

  @impl true
  def update(%{membership: membership} = assigns, socket) do
    club_id = membership.club.id

    contacts =
      case membership.contact do
        nil -> Personal.list_contacts(club_id)
        _ -> [membership.contact]
      end

    departments =
      case membership.department do
        nil -> Organization.list_departments(club_id, :fees)
        _ -> [membership.department]
      end

    groups =
      case membership.group do
        nil -> []
        _ -> [membership.group]
      end

    changeset = Membership.changeset(membership, %{})

    socket =
      socket
      |> assign(assigns)
      |> assign(departments: departments)
      |> assign(groups: groups)
      |> assign(contacts: contacts)
      |> assign(duplicated_membership_error: nil)
      |> assign(contract_warnings: %{})
      |> assign(form: to_form(changeset))
      |> update_fee_options()
      |> update_group_options()
      |> update_duplicated_membership_hint()
      |> update_contract_warnings()

    {:ok, socket}
  end

  @impl true
  def handle_event(
        "apply-contract-action",
        %{"key" => "set_start_date", "new_value" => new_value, "contract" => contract},
        socket
      ) do
    IO.inspect(new_value)

    {:ok, new_date} = Date.from_iso8601(new_value)

    socket =
      apply_contract_action(socket, contract, start_date: new_date)
      |> update_contract_warnings()

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "apply-contract-action",
        %{"key" => "set_termination_date", "new_value" => new_value, "contract" => contract},
        socket
      ) do
    {:ok, new_date} = Date.from_iso8601(new_value)

    socket =
      apply_contract_action(socket, contract, termination_date: new_date)
      |> update_contract_warnings()

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    membership = Personal.get_membership!(id)
    {:ok, _} = Personal.delete_membership(membership)

    {:noreply,
     socket
     |> put_flash(:info, "Mitgliedschaft erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{membership.club_id}/memberships")}
  end

  @impl true
  def handle_event("add-contract", _, socket) do
    new_contract = %Contract{
      club_id: socket.assigns.club.id,
      signing_date: Date.utc_today(),
      start_date: Date.utc_today()
    }

    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing = Changeset.get_assoc(changeset, :contracts)
        changeset = Changeset.put_assoc(changeset, :contracts, existing ++ [new_contract])
        to_form(changeset)
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove-contract", %{"index" => index}, socket) do
    index = String.to_integer(index)

    socket =
      update(socket, :form, fn %{source: changeset} ->
        contracts = Changeset.get_assoc(changeset, :contracts)
        contract_to_delete = Enum.at(contracts, index)

        contracts =
          if contract_to_delete != nil && contract_to_delete.data != nil &&
               contract_to_delete.data.id != nil do
            oldValue = Changeset.get_change(changeset, :deleted)
            newValue = if oldValue != true, do: true, else: false
            contract_to_delete = Changeset.change(contract_to_delete, deleted: newValue)
            List.replace_at(contracts, index, contract_to_delete)
          else
            List.delete_at(contracts, index)
          end

        changeset = Changeset.put_assoc(changeset, :contracts, contracts)
        to_form(changeset)
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"membership" => params}, socket) do
    changeset =
      socket.assigns.membership
      |> Membership.changeset(params)
      |> struct!(action: :validate)

    socket =
      assign(socket, form: to_form(changeset))
      |> sync_contracts()
      |> update_fee_options()
      |> update_group_options()
      |> update_duplicated_membership_hint()
      |> update_contract_warnings()

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"membership" => params}, socket) do
    changeset =
      socket.assigns.membership
      |> Membership.changeset(params)

    socket =
      socket
      |> assign(form: to_form(changeset))
      |> sync_contracts()
      |> update_fee_options()
      |> update_group_options()
      |> update_duplicated_membership_hint()
      |> update_contract_warnings()

    socket =
      cond do
        changeset.valid? == false ->
          IO.puts("changes are not valid")
          IO.inspect(changeset)

          socket
          |> update(:form, fn %{source: changeset} ->
            changeset = struct!(changeset, action: :validate)
            to_form(changeset)
          end)
          |> put_flash(:error, "Die Eingabe ist nicht gültig")

        true ->
          case socket.assigns.membership.id do
            nil -> create_membership(socket, changeset)
            _ -> update_membership(socket, changeset)
          end
      end

    {:noreply, socket}
  end

  defp update_membership(socket, %Changeset{} = changeset) do
    case Personal.update_membership(changeset) do
      {:ok, membership} ->
        socket
        |> put_flash(:info, "Mitgliedschaft erfolgreich aktualisiert")
        |> push_navigate(to: ~p"/memberships/#{membership.id}")

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign(form: to_form(changeset))
        |> put_flash(:error, "Fehler beim Speichern der Eingabe")
    end
  end

  defp create_membership(socket, %Changeset{} = changeset) do
    case Personal.create_membership(changeset) do
      {:ok, membership} ->
        socket
        |> put_flash(:info, "Mitgliedschaft erfolgreich erstellt")
        |> push_navigate(to: ~p"/memberships/#{membership.id}")

      {:error, %Changeset{} = changeset} ->
        socket
        |> assign(form: to_form(changeset))
        |> put_flash(:error, "Fehler beim Speichern der Eingabe")
    end
  end

  defp update_group_options(socket) do
    department_id = get_form_value(socket, :group_id)

    groups =
      if department_id == nil do
        []
      else
        Organization.list_groups(department_id, :fees)
      end

    assign(socket, groups: groups)
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

  defp update_duplicated_membership_hint(socket) do
    contact =
      case get_form_value(socket, :contact_id) do
        nil -> nil
        contact_id -> find_by_id(socket.assigns.contacts, contact_id)
      end

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

    club = socket.assigns.club

    edited_membership_id = get_form_value(socket, :id)

    {matching_memberships, object} =
      cond do
        contact == nil ->
          {[], nil}

        group != nil ->
          {Personal.list_memberships_of_contact_in_group(contact.id, group.id), group}

        department != nil ->
          {Personal.list_memberships_of_contact_in_department(contact.id, department.id),
           department}

        true ->
          {Personal.list_memberships_of_contact_in_club(contact.id, club.id), club}
      end

    duplicated_memberships =
      Enum.filter(matching_memberships, fn m -> m.id !== edited_membership_id end)

    cond do
      length(duplicated_memberships) == 0 ->
        assign(socket, :duplicated_membership_error, nil)

      true ->
        other_id = Enum.at(duplicated_memberships, 0).id
        contact_name = contact.name
        object_name = object.name

        assign(socket, :duplicated_membership_error, %{
          other_id: other_id,
          contact_name: contact_name,
          object_name: object_name
        })
    end
  end

  defp sync_contracts(socket) do
    update(socket, :form, fn %{source: changeset} ->
      contact =
        case get_value(changeset, :contact_id) do
          nil -> nil
          contact_id -> find_by_id(socket.assigns.contacts, contact_id)
        end

      contact_id = if contact == nil, do: nil, else: contact.id

      contract_changeset =
        Changeset.get_assoc(changeset, :contracts)
        |> Enum.map(fn contract_changeset ->
          Changeset.put_change(contract_changeset, :contact_id, contact_id)
        end)

      changeset = Changeset.put_assoc(changeset, :contracts, contract_changeset)
      to_form(changeset)
    end)
  end

  defp update_contract_warnings(socket) do
    contact =
      case get_form_value(socket, :contact_id) do
        nil -> nil
        contact_id -> find_by_id(socket.assigns.contacts, contact_id)
      end

    %Ecto.Changeset{} = changeset = socket.assigns.form.source
    contract_changesets = Changeset.get_assoc(changeset, :contracts)

    warnings =
      Enum.map(contract_changesets, fn contract_changeset ->
        fee_id = get_value(contract_changeset, :fee_id)

        fee =
          case fee_id do
            nil ->
              nil

            _ ->
              find_by_id(socket.assigns.fees, fee_id)
          end

        start_date = get_value(contract_changeset, :start_date)
        termination_date = get_value(contract_changeset, :termination_date)

        cond do
          contact == nil || fee == nil -> nil
          !Contact.is_person?(contact) -> nil
          true -> compare_fees_and_ages(contact, fee, start_date, termination_date)
        end
      end)

    warning_map =
      Enum.with_index(warnings)
      |> Enum.filter(fn {warning, _} -> warning != nil end)
      |> Enum.map(fn {warning, index} -> {index, warning} end)
      |> Enum.into(%{})

    assign(socket, :contract_warnings, warning_map)
  end

  defp compare_fees_and_ages(contact, fee, start_date, termination_date) do
    warnings = []

    warnings =
      cond do
        fee.minimum_age_in_years != nil &&
            (start_date == nil ||
               Contact.age_in_years(contact, start_date) < fee.minimum_age_in_years) ->
          hint =
            "Die Gebühr ist erst ab einem Alter von #{fee.minimum_age_in_years} Jahren gültig"

          action =
            %{
              key: "set_start_date",
              new_value: add_years(contact.person_birthday, fee.minimum_age_in_years)
            }

          warnings ++ [%{hint: hint, action: action}]

        true ->
          warnings
      end

    warnings =
      cond do
        fee.maximum_age_in_years != nil &&
            (termination_date == nil ||
               Contact.age_in_years(contact, termination_date) > fee.maximum_age_in_years) ->
          hint =
            "Die Gebühr ist nur bis zu einem Alter von #{fee.maximum_age_in_years} Jahren gültig"

          # propose day before birthday as termination_date
          max_termination_date = add_years(contact.person_birthday, fee.maximum_age_in_years + 1)
          max_termination_date = Date.add(max_termination_date, -1)
          IO.inspect(max_termination_date)
          IO.inspect( Date.utc_today())
          IO.inspect(max_termination_date < Date.utc_today())
          action = cond do
              start_date != nil && Date.before?(start_date, max_termination_date) -> nil
              Date.before?(max_termination_date, Date.utc_today()) -> nil
              true ->
                  %{
                    key: "set_termination_date",
                    new_value: max_termination_date
                  }
          end

          warnings ++ [%{hint: hint, action: action}]

        true ->
          warnings
      end

    cond do
      length(warnings) == 0 ->
        nil

      true ->
        warnings
    end
  end

  def print_contract_action(%{:key => "set_start_date", :new_value => new_value}) do
    "Startdatum auf #{CommonHelper.format_date_field_dmy(new_value)} setzten"
  end

  def print_contract_action(%{:key => "set_termination_date", :new_value => new_value}) do
    "Enddatum auf #{CommonHelper.format_date_field_dmy(new_value)} setzten"
  end

  defp apply_contract_action(socket, contract_index, changes) do
    update(socket, :form, fn %{source: changeset} ->
      contracts = Changeset.get_assoc(changeset, :contracts)
      contract_to_change = Enum.at(contracts, contract_index)
      contract_to_change = Changeset.change(contract_to_change, changes)
      contracts = List.replace_at(contracts, contract_index, contract_to_change)

      changeset = Changeset.put_assoc(changeset, :contracts, contracts)
      |> struct!(action: :validate)
      to_form(changeset)
    end)
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

  def add_years(%Date{} = date, years_to_add) do
    {:ok, newDate} = Date.new(date.year + years_to_add, date.month, date.day)
    newDate
  end

  def print_contract(contract) do
    if Contact.is_person?(contract) do
      age_in_years = Contact.age_in_years(contract)
      gender = CommonHelper.get_key_for_value(Contact.get_valid_genders(), contract.person_gender)
      "#{contract.name} (#{age_in_years}, #{gender})"
    else
      contract.name
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
