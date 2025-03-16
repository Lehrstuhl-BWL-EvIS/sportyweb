defmodule SportywebWeb.Membership.FormComponent do
  use SportywebWeb, :live_component
  import Ecto.Changeset

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
                print_function={&print_contract(&1)}
              />
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
                print_function={& &1.name}
              />
            </div>

            <div class="col-span-12 md:col-span-3">
              <.input field={@form[:start_date]} type="date" label="Startdatum" />
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
              <.header level="5" class="mt-2">
                Beitrag
              </.header>
            </div>
            <div class="col-span-12 md:col-span-2">
              <.button class="mt-2" type="button" phx-target={@myself} phx-click="add-contract">
                Add
              </.button>
            </div>
            <.inputs_for :let={f_contract} field={@form[:contracts]}>
              <div class="col-span-12 md:col-span-12">
                <.contract_line parent={@myself} contract={f_contract} fees={@fees} />
              </div>
            </.inputs_for>
          </.input_grid>
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
        prompt="Bitte auswählen"
      />
    </div>
    <div :if={@read_only}>
      <.label>{@label}</.label>
      {print_wanted_element(@options, @form[@field].value, @print_function)}
    </div>
    """
  end

  attr :fees, :any
  attr :contract, :any
  attr :parent, :any

  def contract_line(assigns) do
    assigns =
      assign(
        assigns,
        :deleted,
        Phoenix.HTML.Form.input_value(assigns.contract, :deleted) == true
      )

    ~H"""
    <div class={if(@deleted, do: "opacity-50")}>
      <input
        type="hidden"
        name={Phoenix.HTML.Form.input_name(@contract, :delete)}
        value={to_string(Phoenix.HTML.Form.input_value(@contract, :delete))}
      />
      <div class="flex gap-4 items-end">
        <div class="hidden">
          <.input field={@contract[:club_id]} type="text" />
          <.input field={@contract[:contact_id]} type="text" />
          <.input field={@contract[:deleted]} type="checkbox" />
        </div>
        <div class="col-span-12 md:col-span-3">
          <.input field={@contract[:signing_date]} type="date" label="Unterzeichnungsdatum" />
        </div>
        <div class="col-span-12 md:col-span-3">
          <.input field={@contract[:start_date]} type="date" label="Ab" />
        </div>
        <div class="col-span-12 md:col-span-3">
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
        <.button
          class="grow-0"
          type="button"
          phx-target={@parent}
          phx-click="remove-contract"
          phx-value-index={@contract.index}
          disabled={@deleted}
        >
          Delete
        </.button>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{membership: membership} = assigns, socket) do
    IO.inspect("update")
    changeset = Membership.changeset(membership, %{})
    club_id = membership.club.id
    department_id = if membership.department, do: membership.department.id, else: nil
    group_id = if membership.group, do: membership.group.id, else: nil

    contacts =
      case membership.contact do
        nil -> Personal.list_contacts(club_id)
        _ -> [membership.contact]
      end

    departments =
      case membership.department do
        nil -> Organization.list_departments(club_id)
        _ -> [membership.department]
      end

    groups =
      case membership.group do
        nil -> []
        _ -> [membership.group]
      end

    socket =
      socket
      |> assign(assigns)
      |> assign(departments: departments)
      |> assign(groups: groups)
      |> assign(contacts: contacts)
      |> set_fees(department_id, group_id)
      |> assign(changeset: changeset)
      |> assign(form: to_form(changeset))

    {:ok, socket}
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
    changeset = socket.assigns.changeset

    contracts = Changeset.get_assoc(changeset, :contracts)
    contract_to_delete = Enum.at(contracts, index)

    contracts =
      if contract_to_delete != nil && contract_to_delete.data != nil do
        contract_to_delete = Changeset.change(contract_to_delete, deleted: true)
        List.replace_at(contracts, index, contract_to_delete)
      else
        List.delete_at(contracts, index)
      end

    changeset = Changeset.put_assoc(changeset, :contracts, contracts)

    socket =
      socket
      |> assign(changeset: changeset)
      |> assign(form: to_form(changeset))

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"membership" => params}, socket) do
    department_id = params["department_id"]
    group_id = params["group_id"]

    groups =
      if department_id == "" do
        []
      else
        Organization.list_groups(department_id)
      end

    changeset =
      socket.assigns.membership
      |> Membership.changeset(params)
      |> sync_contracts()
      |> struct!(action: :validate)

    socket =
      socket
      |> set_fees(department_id, group_id)
      |> assign(groups: groups)
      |> assign(changeset: changeset)
      |> assign(form: to_form(changeset))

    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"membership" => params}, socket) do
    changeset =
      socket.assigns.membership
      |> Membership.changeset(params)
      |> sync_contracts()

    cond do
      changeset.valid? == false ->
        IO.puts("changes are not valid")
        IO.inspect(changeset)

        socket
        |> assign(changeset: changeset)
        |> assign(form: to_form(changeset))

        {:noreply, socket}

      true ->
        case socket.assigns.membership.id do
          nil -> create_membership(socket, changeset)
          _ -> update_membership(socket, changeset)
        end
    end
  end

  defp sync_contracts(changeset) do
    contact_id =
      case Changeset.get_change(changeset, :contact_id) do
        nil -> Changeset.get_field(changeset, :contact_id)
        value -> value
      end

    contract_changesets = Changeset.get_assoc(changeset, :contracts)

    updated_contracts =
      Enum.map(contract_changesets, fn contract_changeset ->
        Changeset.put_change(contract_changeset, :contact_id, contact_id)
      end)

    Changeset.put_assoc(changeset, :contracts, updated_contracts)
  end

  defp set_fees(socket, department_id, group_id) do
    fees =
      cond do
        group_id != nil && group_id != "" -> Organization.get_group!(group_id, :fees).fees
        department_id != nil && department_id != "" -> Organization.get_department!(department_id, :fees).fees
        true -> Finance.list_general_fees(socket.assigns.club.id, "club")
      end

    assign(socket, fees: fees)
  end

  defp update_membership(socket, %Changeset{} = changeset) do
    socket =
      case Personal.update_membership(changeset) do
        {:ok, membership} ->
          socket
          |> put_flash(:info, "Mitgliedschaft erfolgreich aktualisiert")
          |> push_navigate(to: ~p"/memberships/#{membership.id}")

        {:error, %Changeset{} = changeset} ->
          IO.puts("error on update")
          IO.inspect(changeset)
          assign(socket, form: to_form(changeset))
      end

    {:noreply, socket}
  end

  defp create_membership(socket, %Changeset{} = changeset) do
    socket =
      case Personal.create_membership(changeset) do
        {:ok, membership} ->
          socket
          |> put_flash(:info, "Mitgliedschaft erfolgreich erstellt")
          |> push_navigate(to: ~p"/memberships/#{membership.id}")

        {:error, %Changeset{} = changeset} ->
          IO.puts("Mitgliedschaft nicht gültig")
          IO.inspect(changeset)

          assign(socket, form: to_form(changeset))
          |> put_flash(:error, "Eingabe nicht gültig")
      end

    {:noreply, socket}
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

  def print_wanted_element(elements, wanted_id, print_function) do
    res =
      case Enum.find(elements, fn e -> e.id == wanted_id end) do
        nil -> nil
        elements -> print_function.(elements)
      end

    CommonHelper.format_string_field(res)
  end
end
