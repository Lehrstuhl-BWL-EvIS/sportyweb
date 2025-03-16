defmodule SportywebWeb.MembershipLive.NewEdit do
  use SportywebWeb, :live_view

  alias Ecto.Changeset
  alias Sportyweb.Organization
  alias Sportyweb.Finance
  alias Sportyweb.Legal.Contract
  alias Sportyweb.Personal
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Personal.Membership

  @impl true
  def render(assigns) do
    ~H"""
    <div>
        <.header>
          {@page_title}
        </.header>

        <.card>
          <.simple_form
            for={@form}
            id="membership-form"
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
                    label={"Kontakt"}
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
                    label={"Abteilung"}
                    print_function={&(&1.name)}
                    />
                </div>
                <div class="col-span-12 md:col-span-6">
                <.select_or_read_only
                    read_only={@membership.id != nil}
                    form={@form}
                    field={:group_id}
                    options={@groups}
                    label={"Gruppe"}
                    print_function={&(&1.name)}
                    />
                </div>

                 <div class="col-span-12 md:col-span-3">
                    <.input field={@form[:start_date]} type="date" label="Startdatum" />
                 </div>
                <div class="col-span-12 md:col-span-3">
                  <.input
                    field={@form[:state]}
                    type="select"
                    label={"Status"}
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
                  <.button class="mt-2" type="button" phx-click="add-contract">Add</.button>
                </div>
                <.inputs_for :let={f_contract} field={@form[:contracts]}>
                    <div class="col-span-12 md:col-span-12">
                        <.contract_line contract={f_contract} fees={@fees}/>
                    </div>
                </.inputs_for>
              </.input_grid>

            </.input_grids>

            <:actions>
              <div>
                <.button phx-disable-with="Speichern...">Speichern</.button>
                <.cancel_button navigate={if @membership.id, do: ~p"/memberships/#{@membership}", else: ~p"/clubs/#{@club}/memberships"}>Abbrechen</.cancel_button>
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
        </.card>
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
      <div class={if @read_only do "hidden"  else "" end}>
        <.input
          field={@form[@field]}
          type="select"
          label={"#{@label} (#{length(@options)})"}
          options={@options |> Enum.map(&{@print_function.(&1), &1.id})}
          prompt="Bitte auswählen"
        />
      </div>
      <div :if={@read_only} >
        <.label>{@label}</.label>
        {print_wanted_element(@options, @form[@field].value, @print_function)}
      </div>
    """
  end

  attr :fees, :any
  attr :contract, :any
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
            phx-click="delete-contract"
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
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :members)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    membership = Personal.get_membership!(id, [:contact, club: [:all_fees], department: [:fees], group: [:fees], contracts: [:fee]])
    departments = if membership.department != nil do
      [membership.department]
     else
      []
    end
    groups = if membership.group != nil do
      [membership.group]
      else
      []
    end
    fees = cond do
      membership.group != nil -> Finance.list_contract_fee_options(membership.group, membership.contact.id)
      membership.department != nil -> Finance.list_contract_fee_options(membership.department, membership.contact.id)
      true -> Finance.list_contract_fee_options(membership.club, membership.contact.id)
    end

    contacts = [membership.contact]
    init(socket, membership.club, departments, groups, contacts, fees, membership)
    |> assign(page_title: "Mitgliedschaft von #{membership.contact.name} in #{Membership.get_smallest_community(membership).name} bearbeiten")
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id, :all_fees)
    departments = Organization.list_departments(club.id)
    contacts = Personal.list_contacts(club.id)
    fees = Finance.list_general_fees(club.id, "club")

    membership = %Membership{
      club_id: club.id,
      club: club,
      state: "active",
      start_date: Date.utc_today,
      department_id: nil,
      group_id: nil,
      contracts: [],
    }

    init(socket, club, departments, [], contacts, fees, membership)
    |> assign(page_title: "Neue Mitgliedschaft anlegen")
  end

  defp init(socket, club, departments, groups, contacts, fees, membership) do
    socket
    |> assign(club: club)
    |> assign(departments: departments)
    |> assign(groups: groups)
    |> assign(contacts: contacts)
    |> assign(fees: fees)
    |> init(membership)
  end

  defp init(socket, membership) do
    changeset = Membership.changeset(membership, %{})
    socket
    |> assign(membership: membership)
    |> assign(changeset: changeset)
    |> assign(form: to_form(changeset))
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
      signing_date: Date.utc_today,
      start_date: Date.utc_today
    }
    socket = update(socket, :form, fn %{source: changeset} ->
      existing = Changeset.get_assoc(changeset, :contracts)
      changeset = Changeset.put_assoc(changeset, :contracts, existing ++ [new_contract])
      to_form(changeset)
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete-contract", %{"index" => index}, socket) do
    index = String.to_integer(index)
    changeset = socket.assigns.changeset

    contracts = Changeset.get_assoc(changeset, :contracts)
    contract_to_delete = Enum.at(contracts, index)
    contracts = if contract_to_delete != nil && contract_to_delete.data != nil do
      contract_to_delete = Changeset.change(contract_to_delete, deleted: true)
      List.replace_at(contracts, index, contract_to_delete)
    else
      List.delete_at(contracts, index)
    end

    changeset = Changeset.put_assoc(changeset, :contracts, contracts)

    socket = socket
    |> assign(changeset: changeset)
    |> assign(form: to_form(changeset))
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"membership" => params}, socket) do
    department_id = params["department_id"]
    groups = if department_id == "" do
        []
      else
        Organization.list_groups(department_id)
    end

    changeset = socket.assigns.membership
                |> Membership.changeset(params)
                |> write_contract_objects()
                |> struct!(action: :validate)

    socket = socket
             |> assign(groups: groups)
             |> assign(changeset: changeset)
             |> assign(form: to_form(changeset))
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", %{"membership" => params}, socket) do
    changeset = socket.assigns.membership
    |> Membership.changeset(params)
    |> write_contract_objects()

    cond do
      changeset.valid? == false ->
        IO.puts("changes are not valid")
        IO.inspect(changeset)
        socket
        |> assign(changeset: changeset)
        |> assign(form: to_form(changeset))
        {:noreply, socket}
      true ->
        case socket.assigns.live_action do
          :edit -> update_membership(socket, changeset)
          :new ->  create_membership(socket, changeset)
        end
    end


  end

  defp write_contract_objects(changeset) do
    contact_id = case Changeset.get_change(changeset, :contact_id) do
      nil -> Changeset.get_field(changeset, :contact_id)
      value -> value
    end

    contract_changesets = Changeset.get_assoc(changeset, :contracts)
    updated_contracts = Enum.map(contract_changesets, fn contract_changeset ->
      Changeset.put_change(contract_changeset, :contact_id, contact_id)
    end)
    Changeset.put_assoc(changeset, :contracts, updated_contracts)
  end

  defp update_membership(socket, %Changeset{} = changeset) do
    socket = case Personal.update_membership(changeset) do
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
    socket = case Personal.create_membership(changeset) do
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
    if (Contact.is_person?(contract)) do
      age_in_years = Contact.age_in_years(contract)
      gender = get_key_for_value(Contact.get_valid_genders(), contract.person_gender)
      "#{contract.name} (#{age_in_years}, #{gender})"
    else
      contract.name
    end
  end

  def print_wanted_element(elements, wanted_id, print_function) do
    res = case Enum.find(elements, fn e -> e.id == wanted_id end) do
      nil -> nil
      elements -> print_function.(elements)
    end
    format_string_field(res)
  end


end
